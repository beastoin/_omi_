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
import 'command_response.dart';
import '../tools/tool_manager.dart';
import '../services/llm_service.dart';
import '../services/tray_service.dart';

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

  // LLM service for grammar correction
  LlmService? _llmService;
  String _apiKey = '';
  bool get hasApiKey => _apiKey.isNotEmpty;

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
    _initializeTools();
    // Settings will be loaded asynchronously before any connection is attempted
  }

  // Initialize with settings loaded
  Future<void> initialize() async {
    await _loadSettings();
    return;
  }

  void _initializeTools() {
    // Register all predefined tools
    PredefinedTools.registerAll(_toolManager);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final oldServerUrl = _serverUrl;
    final oldUid = _uid;
    
    _serverUrl = prefs.getString('server_url') ?? _serverUrl;
    _uid = prefs.getString('uid') ?? _uid;
    debugPrint("load settings ${_uid}");
    _autoReconnect = prefs.getBool('auto_reconnect') ?? _autoReconnect;
    _autoPaste = prefs.getBool('auto_paste') ?? _autoPaste;
    _keywordDetection = prefs.getBool('keyword_detection') ?? _keywordDetection;
    _apiKey = prefs.getString('api_key') ?? '';

    // Initialize LLM service if API key is available
    if (_apiKey.isNotEmpty) {
      _llmService = LlmService(apiKey: _apiKey);
    }

    // Load keywords from preferences
    final keywordsJson = prefs.getStringList('keywords');
    if (keywordsJson != null && keywordsJson.isNotEmpty) {
      _keywords = keywordsJson;
    }
    notifyListeners();
    
    // Check if connection-related settings were changed
    bool needsReconnect = (oldServerUrl != _serverUrl || oldUid != _uid);
    
    // Reconnect if connection-related settings were changed and we're currently connected
    if (needsReconnect && _status == ConnectionStatus.connected) {
      disconnect();
      await Future.delayed(const Duration(milliseconds: 500)); // Brief delay before reconnecting
      connect();
    }
  }

  Future<void> saveSettings({
    String? serverUrl,
    String? uid,
    bool? autoReconnect,
    bool? autoPaste,
    bool? keywordDetection,
    List<String>? keywords,
    String? apiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool needsReconnect = false;

    if (serverUrl != null && serverUrl != _serverUrl) {
      _serverUrl = serverUrl;
      await prefs.setString('server_url', serverUrl);
      needsReconnect = true;
    }

    if (uid != null && uid != _uid) {
      _uid = uid;
      await prefs.setString('uid', uid);
      needsReconnect = true;
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

    if (apiKey != null) {
      _apiKey = apiKey;
      await prefs.setString('api_key', apiKey);

      // Initialize or update LLM service
      if (apiKey.isNotEmpty) {
        _llmService = LlmService(apiKey: apiKey);
      } else {
        _llmService = null;
      }
    }

    notifyListeners();
  }

  Future<void> connect() async {
    // Ensure settings are loaded before connecting
    if (_status == ConnectionStatus.connecting) return;

    _status = ConnectionStatus.connecting;
    _errorMessage = '';
    notifyListeners();

    // Make sure settings are loaded before connecting
    debugPrint("Connecting with UID: $_uid");

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

  // Keep track of recent segments to handle split keywords
  final List<TranscriptSegment> _recentSegments = [];
  final int _maxRecentSegments = 5; // Keep track of last 5 segments

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

      // Add new segments to recent segments list
      _recentSegments.addAll(newSegments);
      // Trim the list if it gets too long
      if (_recentSegments.length > _maxRecentSegments) {
        _recentSegments.removeRange(0, _recentSegments.length - _maxRecentSegments);
      }

      // First check for keywords in both new segments and recent context
      if (newSegments.isNotEmpty) {
        // Check keywords in new segments first
        if (!_checkForKeyword(newSegments)) {
          // If no keyword found, check with recent context for split keywords
          if (!_isRecordingCommand && !_checkForKeyword(_recentSegments)) {
            // If still no keyword found, auto-paste if appropriate
            _autoPasteNewSegments(newSegments);
          }
        }
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

      // Simulate Cmd+V keystroke
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

  bool _checkForKeyword(List<TranscriptSegment> segments) {
    if (!_keywordDetection) return false;

    // Normalize text by removing commas and extra spaces
    String normalizeText(String text) {
      return text.toLowerCase()
          .replaceAll(',', ' ')  // Replace commas with spaces
          .replaceAll('.', ' ')  // Replace periods with spaces
          .replaceAll(RegExp(r'\s+'), ' ')  // Replace multiple spaces with single space
          .trim();
    }

    // Combine all new segment texts to check for the keywords
    final String combinedText = normalizeText(segments.map((s) => s.text).join(' '));

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

        // Show notification in system tray
        TrayService().showNotification(
          "Command Completed", 
          "Command recorded: $finalCommand (${duration.inSeconds}s)"
        );

        // Reset command recording state
        _isRecordingCommand = false;
        _currentCommand = "";
        _commandStartTime = null;
        
        // Clear recent segments to avoid recalling old commands
        _recentSegments.clear();
        
        // Reset the recording icon state
        TrayService().setRecordingIcon(false);
        
        // Still notify listeners to update UI
        notifyListeners();
      }
      return true;
    }

    // Not recording yet, check for trigger keywords
    if (_keywords.isEmpty) return false;

    // Check for any of the keywords in the list
    for (final keyword in _keywords) {
      // Normalize the keyword as well
      String normalizedKeyword = normalizeText(keyword);
      
      // Check if the normalized keyword is in the normalized text
      if (combinedText.contains(normalizedKeyword)) {
        // Start recording the command but exclude the trigger keyword
        _isRecordingCommand = true;
        _commandStartTime = DateTime.now();

        // Remove the trigger keyword from the initial command text
        String initialCommand = combinedText;
        // Find the end of the keyword in the text
        int keywordEndIndex = initialCommand.indexOf(normalizedKeyword) + normalizedKeyword.length;
        // Only keep text after the keyword
        if (keywordEndIndex < initialCommand.length) {
          initialCommand = initialCommand.substring(keywordEndIndex).trim();
        } else {
          initialCommand = "";
        }

        _currentCommand = initialCommand;
        
        // Clear recent segments to avoid recalling old commands
        _recentSegments.clear();

        // Show notification in system tray with more noticeable message
        TrayService().showNotification(
          "Command Recording Started", 
          "Recording command... Say 'over' when finished."
        );
        
        // Explicitly set the recording icon state
        TrayService().setRecordingIcon(true);

        // Still notify listeners to update UI
        notifyListeners();

        // Break after first match to avoid multiple recordings
        break;
      }
    }

    return _isRecordingCommand;
  }

  Future<void> _processCommand(String command) async {
    // Show notification in system tray
    TrayService().showNotification(
      "Command Processing", 
      "Processing command..."
    );
    
    notifyListeners();

    try {
      // Process the command using the tool manager
      final response = await _toolManager.processCommand(command);

      if (!response.success) {
        // Handle error
        TrayService().showNotification(
          "Command Error", 
          response.errorMessage ?? "Unknown error"
        );
        notifyListeners();
        return;
      }

      // Handle different response types
      switch (response.type) {
        case CommandResponseType.autoPasteToggle:
          final action = response.content;
          bool newState;

          if (action == "ON") {
            newState = true;
          } else if (action == "OFF") {
            newState = false;
          } else {
            // TOGGLE
            newState = !_autoPaste;
          }

          // Update auto-paste setting
          await saveSettings(autoPaste: newState);

          // Show notification in system tray
          TrayService().showNotification(
            "Auto-Paste Setting", 
            newState ? "Auto-paste has been turned ON" : "Auto-paste has been turned OFF"
          );
          break;

        case CommandResponseType.grammarCorrection:
          // Handle grammar correction
          await _correctGrammar(response.content);
          break;

        case CommandResponseType.writingEnhancement:
          // Handle writing enhancement
          final instruction = response.parameters['instruction'] ?? 'professional';
          await _enhanceWriting(response.content, instruction);
          break;

        case CommandResponseType.text:
        default:
          // Show notification in system tray with the result
          TrayService().showNotification(
            "Command Result", 
            response.content
          );
          break;
      }

      notifyListeners();
    } catch (e) {
      // Show error notification in system tray
      TrayService().showNotification(
        "Command Error", 
        "Error processing command: $e"
      );
      
      notifyListeners();
    }
  }

  /// Get all available tools
  List<Tool> get availableTools => _toolManager.tools;

  /// Corrects grammar in the provided text and pastes the result
  Future<void> _correctGrammar(String text) async {
    if (_llmService == null) {
      // Show notification in system tray
      TrayService().showNotification(
        "Grammar Correction Error", 
        "API key not set. Please set an OpenAI API key in settings."
      );
      
      notifyListeners();
      return;
    }

    try {
      // Show notification in system tray
      TrayService().showNotification(
        "Grammar Correction", 
        "Correcting grammar..."
      );
      
      notifyListeners();

      // Get corrected text from LLM
      final correctedText = await _llmService!.correctGrammar(text);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: correctedText));

      // Simulate Cmd+V keystroke to paste
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );

      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );

      // Show notification in system tray
      TrayService().showNotification(
        "Grammar Correction", 
        "Grammar corrected and pasted"
      );
      
      notifyListeners();
    } catch (e) {
      // Show notification in system tray
      TrayService().showNotification(
        "Grammar Correction Error", 
        "Error correcting grammar: $e"
      );
      
      notifyListeners();
    }
  }

  /// Enhances writing according to a specified instruction and pastes the result
  Future<void> _enhanceWriting(String text, String instruction) async {
    if (_llmService == null) {
      // Show notification in system tray
      TrayService().showNotification(
        "Writing Enhancement Error", 
        "API key not set. Please set an OpenAI API key in settings."
      );
      
      notifyListeners();
      return;
    }

    try {
      // Show notification in system tray
      TrayService().showNotification(
        "Writing Enhancement", 
        "Enhancing writing with '$instruction' instruction..."
      );
      
      notifyListeners();

      // Get enhanced text from LLM
      final enhancedText = await _llmService!.enhanceWriting(text, instruction);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: enhancedText));

      // Simulate Cmd+V keystroke to paste
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );

      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );

      // Show notification in system tray
      TrayService().showNotification(
        "Writing Enhancement", 
        "Writing enhanced with '$instruction' instruction and pasted"
      );
      
      notifyListeners();
    } catch (e) {
      // Show notification in system tray
      TrayService().showNotification(
        "Writing Enhancement Error", 
        "Error enhancing writing: $e"
      );
      
      notifyListeners();
    }
  }

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
