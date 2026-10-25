import 'package:url_launcher/url_launcher.dart';

class MapsService {
  static Uri getGoogleMapsUri({
    required double latitude,
    required double longitude,
    required String label,
  }) {
    // Encodes destination label and coordinates for standard Google Maps browser and native app intent
    final query = Uri.encodeComponent('$label, $latitude,$longitude');
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  }

  static Future<bool> openLocation({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    final uri = getGoogleMapsUri(
      latitude: latitude,
      longitude: longitude,
      label: label,
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Fallback to in-app webview or standard launch
        return await launchUrl(uri);
      }
      return launched;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openSearch(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
