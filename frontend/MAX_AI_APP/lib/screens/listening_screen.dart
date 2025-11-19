import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:max_ai/services/websocket_service.dart';
import 'package:max_ai/services/action_service.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late WebSocketService _wsService;
  final ActionService _actionService = ActionService();
  
  bool _isListening = false;
  String _text = "Tap the mic to start speaking...";
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initVoice();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    // Default to localhost, retry logic handles emulator
    String backendUrl = 'ws://localhost:8000/api/v1/ws/stream';
    
    _wsService = WebSocketService(
      url: backendUrl,
      onMessage: _handleServerResponse,
      onError: (error) {
        print("WS Error: $error");
        if (mounted) setState(() => _isConnected = false);
        if (backendUrl.contains('localhost')) {
           _retryConnect('ws://10.0.2.2:8000/api/v1/ws/stream');
        }
      },
    );
    _wsService.connect();
    if (mounted) setState(() => _isConnected = true);
  }

  void _retryConnect(String url) {
     _wsService = WebSocketService(
      url: url,
      onMessage: _handleServerResponse,
      onError: (error) {
        print("WS Retry Error: $error");
        if (mounted) setState(() => _isConnected = false);
      },
    );
    _wsService.connect();
  }

  Future<void> _initVoice() async {
    await Permission.microphone.request();
    bool available = await _speech.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (errorNotification) => print('STT Error: $errorNotification'),
    );
    if (available) {
      print("STT Initialized");
    } else {
      print("STT not available");
    }
    
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
            if (val.hasConfidenceRating && val.confidence > 0) {
               // Partial results
            }
            if (val.finalResult) {
               _sendMessage(_text);
               setState(() => _isListening = false);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage(String text) {
    if (text.isEmpty) return;
    print("Sending: $text");
    _wsService.sendText(text);
  }

  void _handleServerResponse(dynamic data) async {
    print("Received: $data");
    if (data['message'] != null) {
      String responseText = data['message'];
      setState(() => _text = responseText);
      await _flutterTts.speak(responseText);
    }
    
    if (data['action'] != null) {
      _actionService.handleAction(data['action']);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020818),
      body: SafeArea(
        child: Column(
          children: [
             // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.wifi, color: _isConnected ? Colors.green : Colors.red),
                  const Icon(Icons.lock_open, color: Colors.white70),
                  const Icon(Icons.mic, color: Colors.white70),
                ],
              ),
            ),
            const Spacer(),
            
            // Transcript / Response
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const Spacer(),
            
            // Visualizer (Static for now)
            GestureDetector(
              onTap: _listen,
              child: _AvatarWithWaveform(isListening: _isListening),
            ),
            
            const Spacer(),
            
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/chat');
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithWaveform extends StatelessWidget {
  final bool isListening;
  const _AvatarWithWaveform({required this.isListening});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF00E0C6), Color(0xFF00101A)],
            ),
            boxShadow: [
              BoxShadow(
                color: isListening ? Colors.tealAccent.withOpacity(0.8) : Colors.tealAccent.withOpacity(0.5),
                blurRadius: isListening ? 60 : 40,
                spreadRadius: isListening ? 20 : 12,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none, 
                color: Colors.white70, 
                size: 40
              ),
            ),
          ),
        ),
      ),
    );
  }
}
