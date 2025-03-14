import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'transcript_segment.dart';
import '../tools/tool_manager.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class TranscriptManager extends ChangeNotifier {
  WebSocketChannel? _channel;
  List<TranscriptSegment> _segments = [];
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _errorMessage = '';
  String _serverUrl = 'ws://localhost:8099/ws';
  String _uid = 'OAEZL1gRvOQmLLg6E3BzjNpEmtf1';
  Timer? _reconnectTimer;
  bool _autoReconnect = true;
  bool _autoPaste = true;
  bool _keywordDetection = true;
  List<String> _keywords = ['112', 'one one two'];
  
  // Command recording variables
  bool _isRecordingCommand = false;
  String _currentCommand = "";
  DateTime? _commandStartTime;
  
  // Tool manager for processing commands
  final ToolManager _toolManager = ToolManager();

  List<TranscriptSegment> get segments => _segments;
  ConnectionStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get serverUrl => _serverUrl;
  String get uid => _uid;
  bool get isConnected => _status == ConnectionStatus.connected;
  bool get autoPaste => _autoPaste;
  bool get keywordDetection => _keywordDetection;
  List<String> get keywords => _keywords;
  bool get isRecordingCommand => _isRecordingCommand;
  String get currentCommand => _currentCommand;

  TranscriptManager() {
    _loadSettings();
    _initializeTools();
  }
  
  void _initializeTools() {
    // Register all predefined tools
    PredefinedTools.registerAll(_toolManager);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('server_url') ?? _serverUrl;
    _uid = prefs.getString('uid') ?? _uid;
    _autoReconnect = prefs.getBool('auto_reconnect') ?? _autoReconnect;
    _autoPaste = prefs.getBool('auto_paste') ?? _autoPaste;
    _keywordDetection = prefs.getBool('keyword_detection') ?? _keywordDetection;
    
    // Load keywords from preferences
    final keywordsJson = prefs.getStringList('keywords');
    if (keywordsJson != null && keywordsJson.isNotEmpty) {
      _keywords = keywordsJson;
    }
    notifyListeners();
  }

  Future<void> saveSettings({
    String? serverUrl,
    String? uid,
    bool? autoReconnect,
    bool? autoPaste,
    bool? keywordDetection,
    List<String>? keywords,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (serverUrl != null) {
      _serverUrl = serverUrl;
      await prefs.setString('server_url', serverUrl);
    }

    if (uid != null) {
      _uid = uid;
      await prefs.setString('uid', uid);
    }

    if (autoReconnect != null) {
      _autoReconnect = autoReconnect;
      await prefs.setBool('auto_reconnect', autoReconnect);
    }

    if (autoPaste != null) {
      _autoPaste = autoPaste;
      await prefs.setBool('auto_paste', autoPaste);
    }

    if (keywordDetection != null) {
      _keywordDetection = keywordDetection;
      await prefs.setBool('keyword_detection', keywordDetection);
    }
    
    if (keywords != null) {
      _keywords = keywords;
      await prefs.setStringList('keywords', keywords);
    }

    notifyListeners();
  }

  Future<void> connect() async {
    if (_status == ConnectionStatus.connecting) return;

    _status = ConnectionStatus.connecting;
    _errorMessage = '';
    notifyListeners();

    try {
      final url = '$_serverUrl?uid=$_uid';
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (message) {
          print("$message");
          _handleMessage(message);
        },
        onDone: _handleDisconnection,
        onError: (error) {
          _status = ConnectionStatus.error;
          _errorMessage = 'Connection error: $error';
          notifyListeners();
          _scheduleReconnect();
        },
      );

      _status = ConnectionStatus.connected;
      notifyListeners();
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = 'Failed to connect: $e';
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_channel != null) {
      _channel!.sink.close(1000); // 1000 is the normal closure code
      _channel = null;
    }

    _status = ConnectionStatus.disconnected;
    notifyListeners();
  }

  void _handleDisconnection() {
    if (_status != ConnectionStatus.disconnected) {
      _status = ConnectionStatus.disconnected;
      _errorMessage = 'Disconnected from server';
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_autoReconnect) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_status != ConnectionStatus.connected) {
        connect();
      }
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      List<TranscriptSegment> newSegments = [];

      if (data is List) {
        // Handle direct list of segments
        newSegments = data.map((json) => TranscriptSegment.fromJson(json)).toList();
        _segments.addAll(newSegments);
        notifyListeners();
      }

      // Auto-paste new transcript text if we received new segments
      if (newSegments.isNotEmpty) {
        _autoPasteNewSegments(newSegments);
        _checkForKeyword(newSegments);
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  Future<void> _autoPasteNewSegments(List<TranscriptSegment> newSegments) async {
    if (!_autoPaste || newSegments.isEmpty) return;

    try {
      // Get text from new segments only
      final text = '${newSegments.map((segment) {
        return segment.text;
      }).join(' ')} '; // Spacing at the end

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: text));

      // Simulate Cmd+V keystrokeI think yes. Right?
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );

      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
    } catch (e) {
      print('Error auto-pasting: $e');
    }
  }

  void clearTranscript() {
    _segments.clear();
    notifyListeners();
  }

  String getTranscriptText() {
    return _segments.map((segment) {
      final speaker = segment.speaker.isNotEmpty ? '[${segment.speaker}]' : '';
      final timestamp = DateFormat('HH:mm:ss').format(segment.timestamp);
      return '$speaker ($timestamp): ${segment.text}';
    }).join('\n\n');
  }

  void _checkForKeyword(List<TranscriptSegment> segments) {
    if (!_keywordDetection) return;

    // Combine all new segment texts to check for the keywords
    final String combinedText = segments.map((s) => s.text.toLowerCase()).join(' ');
    
    // Check if we're already recording a command
    if (_isRecordingCommand) {
      // Add the new text to the current command
      _currentCommand += " $combinedText";
      
      // Check if the "over" keyword is present to end the command
      if (combinedText.contains('over')) {
        // Finalize the command
        final endIndex = _currentCommand.lastIndexOf('over');
        final finalCommand = _currentCommand.substring(0, endIndex).trim();
        
        // Calculate duration
        final duration = DateTime.now().difference(_commandStartTime!);
        
        // Process the command
        _processCommand(finalCommand);
        
        // Show the completed command notification
        _errorMessage = "Command recorded: $finalCommand (${duration.inSeconds}s)";
        notifyListeners();
        
        // Reset command recording state
        _isRecordingCommand = false;
        _currentCommand = "";
        _commandStartTime = null;
        
        // Reset error message after a delay
        Timer(const Duration(seconds: 3), () {
          _errorMessage = "";
          notifyListeners();
        });
      }
      return;
    }
    
    // Not recording yet, check for trigger keywords
    if (_keywords.isEmpty) return;
    
    // Check for any of the keywords in the list
    for (final keyword in _keywords) {
      if (combinedText.toLowerCase().contains(keyword.toLowerCase())) {
        // Start recording the command but exclude the trigger keyword
        _isRecordingCommand = true;
        _commandStartTime = DateTime.now();
        
        // Remove the trigger keyword from the initial command text
        String initialCommand = combinedText;
        // Find the end of the keyword in the text
        int keywordEndIndex = initialCommand.toLowerCase().indexOf(keyword.toLowerCase()) + keyword.length;
        // Only keep text after the keyword
        if (keywordEndIndex < initialCommand.length) {
          initialCommand = initialCommand.substring(keywordEndIndex).trim();
        } else {
          initialCommand = "";
        }
        
        _currentCommand = initialCommand;
        
        // Notify listeners to show a toast notification
        _errorMessage = "I am here - Recording command...";
        notifyListeners();
        
        // Break after first match to avoid multiple recordings
        break;
      }
    }
  }

  Future<void> _processCommand(String command) async {
    _errorMessage = "Processing command...";
    notifyListeners();
    
    try {
      // Process the command using the tool manager
      final result = await _toolManager.processCommand(command);
      
      // Handle special commands
      if (result.startsWith("AUTO_PASTE_TOGGLE:")) {
        final action = result.split(":")[1];
        bool newState;
        
        if (action == "ON") {
          newState = true;
        } else if (action == "OFF") {
          newState = false;
        } else { // TOGGLE
          newState = !_autoPaste;
        }
        
        // Update auto-paste setting
        await saveSettings(autoPaste: newState);
        
        _errorMessage = newState 
            ? "Auto-paste has been turned ON" 
            : "Auto-paste has been turned OFF";
      } else {
        // Update the error message with the result
        _errorMessage = result;
      }
      
      notifyListeners();
      
      // Reset error message after a delay
      Timer(const Duration(seconds: 3), () {
        _errorMessage = "";
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = "Error processing command: $e";
      notifyListeners();
      
      // Reset error message after a delay
      Timer(const Duration(seconds: 3), () {
        _errorMessage = "";
        notifyListeners();
      });
    }
  }
  
  /// Get all available tools
  List<Tool> get availableTools => _toolManager.tools;
  
  /// Register a new tool
  void registerTool(Tool tool) {
    _toolManager.registerTool(tool);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
