import 'package:url_launcher/url_launcher.dart';

abstract final class MapLauncher {
  static Future<bool> openDirections({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final query = label != null && label.isNotEmpty
        ? Uri.encodeComponent(label)
        : '$latitude,$longitude';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
