import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String url;
  final Function(dynamic) onMessage;
  final Function(dynamic) onError;

  WebSocketService({
    required this.url,
    required this.onMessage,
    required this.onError,
  });

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (message) {
          onMessage(jsonDecode(message));
        },
        onError: (error) {
          onError(error);
        },
        onDone: () {
          // Handle disconnect
        },
      );
    } catch (e) {
      onError(e);
    }
  }

  void sendText(String text) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "text",
        "content": text,
      }));
    }
  }

  void sendAudio(String base64Audio) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "audio",
        "content": base64Audio,
      }));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
