import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUtil {
  /// Returns the full URL of the image based on the provided image path.
  String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    final serverUrl = dotenv.env['SERVER_IP'] ?? '';
    return '$serverUrl$imageUrl';
  }
}
