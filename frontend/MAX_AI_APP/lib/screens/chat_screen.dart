import 'package:flutter/material.dart';
import 'package:max_ai/services/websocket_service.dart';
import 'package:max_ai/services/action_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late WebSocketService _wsService;
  final ActionService _actionService = ActionService();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    // Detect platform and choose URL
    // Android Emulator: 10.0.2.2
    // iOS Simulator / Web: localhost
    // Physical Device: Use your computer's LAN IP (e.g. 192.168.1.x)
    
    String backendUrl = 'ws://localhost:8000/api/v1/ws/stream';
    
    // Simple check for Android emulator (this is a heuristic, better to use Platform.isAndroid)
    // For now, we'll try to be smart or let user configure it.
    // Ideally, use 'dart:io' Platform check, but web compatibility requires conditional imports.
    // We will stick to localhost for iOS/Web and 10.0.2.2 for Android if possible.
    // Since we can't easily import dart:io in a universal file without conditional imports,
    // we will default to localhost but add a comment for the user.
    
    // NOTE: If running on Android Emulator, change this to 'ws://10.0.2.2:8000/api/v1/ws/stream'
    // backendUrl = 'ws://10.0.2.2:8000/api/v1/ws/stream';
    
    _wsService = WebSocketService(
      url: backendUrl,
      onMessage: _handleMessage,
      onError: (error) {
        print("WS Error: $error");
        setState(() => _isConnected = false);
        
        // Auto-retry with Android URL if localhost fails (simple fallback logic)
        if (backendUrl.contains('localhost')) {
           print("Retrying with Android Emulator URL...");
           _retryConnect('ws://10.0.2.2:8000/api/v1/ws/stream');
        }
      },
    );
    _wsService.connect();
    setState(() => _isConnected = true);
  }

  void _retryConnect(String url) {
     _wsService = WebSocketService(
      url: url,
      onMessage: _handleMessage,
      onError: (error) {
        print("WS Retry Error: $error");
        setState(() => _isConnected = false);
      },
    );
    _wsService.connect();
  }

  void _handleMessage(dynamic data) {
    if (data['message'] != null) {
      setState(() {
        _messages.add({
          'text': data['message'],
          'isUser': false,
          'time': _getCurrentTime(),
        });
      });
    }
    
    if (data['action'] != null) {
      _actionService.handleAction(data['action']);
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    final text = _controller.text;
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': _getCurrentTime(),
      });
      _controller.clear();
    });
    
    _wsService.sendText(text);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _wsService.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050812),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('JARVIS', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _connect,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return msg['isUser']
                    ? _UserBubble(text: msg['text'], time: msg['time'])
                    : _AssistantBubble(text: msg['text'], time: msg['time']);
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: const Color(0xFF020617),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask JARVIS...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF020818),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.tealAccent),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final String text;
  final String time;

  const _AssistantBubble({required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final String time;

  const _UserBubble({required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF047857),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
