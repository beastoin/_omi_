import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'transcript_segment.dart';

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

  List<TranscriptSegment> get segments => _segments;
  ConnectionStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get serverUrl => _serverUrl;
  bool get isConnected => _status == ConnectionStatus.connected;
  bool get autoPaste => _autoPaste;

  TranscriptManager() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('server_url') ?? _serverUrl;
    _autoReconnect = prefs.getBool('auto_reconnect') ?? _autoReconnect;
    _autoPaste = prefs.getBool('auto_paste') ?? _autoPaste;
    notifyListeners();
  }

  Future<void> saveSettings({String? serverUrl, bool? autoReconnect, bool? autoPaste}) async {
    final prefs = await SharedPreferences.getInstance();

    if (serverUrl != null) {
      _serverUrl = serverUrl;
      await prefs.setString('server_url', serverUrl);
    }

    if (autoReconnect != null) {
      _autoReconnect = autoReconnect;
      await prefs.setBool('auto_reconnect', autoReconnect);
    }
    
    if (autoPaste != null) {
      _autoPaste = autoPaste;
      await prefs.setBool('auto_paste', autoPaste);
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
      } else if (data is Map<String, dynamic> && data.containsKey('segments')) {
        // Handle wrapped segments format
        final List<dynamic> segmentsJson = data['segments'];
        newSegments = segmentsJson.map((json) => TranscriptSegment.fromJson(json)).toList();
        _segments.addAll(newSegments);
        notifyListeners();
      }
      
      // Auto-paste new transcript text if we received new segments
      if (newSegments.isNotEmpty) {
        _autoPasteNewSegments(newSegments);
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }
  
  Future<void> _autoPasteNewSegments(List<TranscriptSegment> newSegments) async {
    if (!_autoPaste) return;
    
    try {
      // Get text from new segments only
      final text = newSegments.map((segment) => segment.text).join(' ');
      
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

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
