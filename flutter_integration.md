# Flutter Integration Guide

This guide provides a high-level overview of how to integrate the Voice AI Backend with a Flutter mobile application.

## 1. Authentication
- **Login**: POST to `/api/v1/auth/token` with `username` (email) and `password`.
- **Storage**: Store the returned `access_token` securely (e.g., using `flutter_secure_storage`).
- **Headers**: Add `Authorization: Bearer <token>` to all subsequent requests.

## 2. Real-Time Voice Streaming (WebSockets)
Use the `web_socket_channel` package to connect to the backend.

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse('ws://YOUR_BACKEND_URL/api/v1/ws/stream'),
);

// Sending Audio (Mock/Placeholder)
// In a real app, stream audio bytes or base64 chunks
channel.sink.add(jsonEncode({
  "type": "audio",
  "content": "base64_encoded_audio_chunk"
}));

// Sending Text
channel.sink.add(jsonEncode({
  "type": "text",
  "content": "Call Mom"
}));

// Listening for Responses
channel.stream.listen((message) {
  final data = jsonDecode(message);
  if (data['action'] != null) {
    handleAction(data['action']);
  }
  if (data['message'] != null) {
    playTts(data['message']); // Pass to TTS engine
  }
});
```

## 3. Handling Actions
The backend returns structured JSON for actions. Map these to Flutter platform channels or plugins.

**Example Response:**
```json
{
  "message": "Calling Mom.",
  "action": {
    "name": "call",
    "params": { "target": "Mom" },
    "needs_confirmation": true
  }
}
```

**Handler Logic:**
```dart
void handleAction(Map<String, dynamic> action) {
  switch (action['name']) {
    case 'call':
      // Use url_launcher or flutter_phone_direct_caller
      launchUrl("tel:${action['params']['target']}");
      break;
    case 'navigation':
      // Use map_launcher
      break;
    // ... handle other skills
  }
}
```

## 4. Text-to-Speech (TTS)
The backend returns the text response. Use a Flutter TTS package (e.g., `flutter_tts`) to speak the response to the user.

## 5. State Management
- Maintain conversation history locally if needed, or rely on the backend's memory.
- Handle WebSocket connection states (connecting, connected, disconnected, error).
