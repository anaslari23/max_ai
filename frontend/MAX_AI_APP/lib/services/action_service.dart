import 'package:url_launcher/url_launcher.dart';

class ActionService {
  Future<void> handleAction(Map<String, dynamic> action) async {
    final name = action['name'];
    final params = action['params'] ?? {};

    switch (name) {
      case 'call':
        await _launchUrl('tel:${params['target']}');
        break;
      case 'sms':
        await _launchUrl('sms:${params['target']}?body=${params['message'] ?? ""}');
        break;
      case 'search':
        await _launchUrl('https://www.google.com/search?q=${params['query']}');
        break;
      case 'navigation':
        // Open Google Maps
        await _launchUrl('https://www.google.com/maps/search/?api=1&query=${params['destination']}');
        break;
      case 'media':
        // Placeholder for media control
        print("Media control: ${params['command']}");
        break;
      default:
        print("Unknown action: $name");
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
