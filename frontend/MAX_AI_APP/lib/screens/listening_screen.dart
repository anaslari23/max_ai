import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:max_ai/services/websocket_service.dart';
import 'package:max_ai/services/action_service.dart';
import 'dart:math' as math;

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late WebSocketService _wsService;
  final ActionService _actionService = ActionService();
  late AnimationController _animController;
  
  bool _isListening = false;
  String _text = "Tap to activate voice interface";
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _initVoice();
    _initTts();
    _connectWebSocket();
  }

  Future<void> _initTts() async {
    try {
      // Configure TTS for iOS
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
      
      // Set language and voice - British English for JARVIS-like feel
      await _flutterTts.setLanguage("en-GB");
      
      // Try to get available voices and select a good one
      var voices = await _flutterTts.getVoices;
      if (voices != null) {
        print("Available voices: $voices");
        
        // Look for a British male voice (Daniel, Arthur, or similar)
        var preferredVoices = ['Daniel', 'Arthur', 'com.apple.voice.compact.en-GB.Daniel'];
        for (var voiceName in preferredVoices) {
          var voice = voices.firstWhere(
            (v) => v['name'].toString().contains(voiceName),
            orElse: () => null,
          );
          if (voice != null) {
            await _flutterTts.setVoice({"name": voice['name'], "locale": voice['locale']});
            print("Selected voice: ${voice['name']}");
            break;
          }
        }
      }
      
      // Voice parameters for a more AI-like sound
      await _flutterTts.setSpeechRate(0.52); // Slightly faster for intelligence
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(0.95); // Slightly lower pitch for authority

      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        print("TTS: Speech completed");
      });

      _flutterTts.setErrorHandler((msg) {
        print("TTS Error: $msg");
      });

      print("TTS initialized successfully with JARVIS voice");
    } catch (e) {
      print("TTS initialization error: $e");
    }
  }

  void _connectWebSocket() {
    String backendUrl = 'ws://localhost:8000/api/v1/ws/stream';
    _wsService = WebSocketService(
      url: backendUrl,
      onMessage: _handleServerResponse,
      onError: (error) {
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
        if (mounted) setState(() => _isConnected = false);
      },
    );
    _wsService.connect();
  }

  Future<void> _initVoice() async {
    await Permission.microphone.request();
    await _speech.initialize();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _text = "Listening...";
        });
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
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
    _wsService.sendText(text);
    setState(() => _text = "Processing...");
  }

  void _handleServerResponse(dynamic data) async {
    print("Server response received: $data");
    
    if (data['message'] != null) {
      String responseText = data['message'];
      setState(() => _text = responseText);
      
      // Stop any ongoing speech before starting new one
      await _flutterTts.stop();
      
      print("Speaking: $responseText");
      var result = await _flutterTts.speak(responseText);
      print("TTS speak result: $result");
    }
    
    if (data['action'] != null) {
      print("Action received: ${data['action']}");
      _actionService.handleAction(data['action']);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _wsService.disconnect();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020617),
              Color(0xFF001219),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Icon(Icons.wifi, color: _isConnected ? const Color(0xFF00E0C6) : Colors.red, size: 20),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Dynamic Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _text,
                    key: ValueKey<String>(_text),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      height: 1.4,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Visualizer
              GestureDetector(
                onTap: _listen,
                child: _RippleVisualizer(
                  isListening: _isListening,
                  controller: _animController,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                _isListening ? "TAP TO STOP" : "TAP TO SPEAK",
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RippleVisualizer extends StatelessWidget {
  final bool isListening;
  final AnimationController controller;

  const _RippleVisualizer({required this.isListening, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isListening) ...[
            _buildRipple(controller, 0.0),
            _buildRipple(controller, 0.3),
            _buildRipple(controller, 0.6),
          ],
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E0C6).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF00E0C6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E0C6).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: const Color(0xFF00E0C6),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(AnimationController controller, double delay) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = (controller.value + delay) % 1.0;
        final opacity = (1.0 - value).clamp(0.0, 1.0).toDouble();
        final scale = 1.0 + (value * 1.5);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00E0C6).withOpacity(opacity * 0.5),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
