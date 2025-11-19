import 'package:flutter/material.dart';
import 'dart:ui';
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
    String backendUrl = 'ws://localhost:8000/api/v1/ws/stream';
    _wsService = WebSocketService(
      url: backendUrl,
      onMessage: _handleMessage,
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
      onMessage: _handleMessage,
      onError: (error) {
        if (mounted) setState(() => _isConnected = false);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        title: const Text('JARVIS', style: TextStyle(color: Colors.white, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          Icon(Icons.circle, size: 10, color: _isConnected ? const Color(0xFF00E0C6) : Colors.red),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050812), Color(0xFF001219)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
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
      ),
    );
  }

  Widget _buildComposer() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Command...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00E0C6),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF00E0C6), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: Colors.white, height: 1.4)),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(color: Colors.white30, fontSize: 10)),
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E0C6), Color(0xFF00BFA6)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E0C6).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text, 
              style: const TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(color: Colors.black45, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
