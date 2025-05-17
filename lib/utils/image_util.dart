import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUtil {
  /// Returns the full URL of the image based on the provided image path.
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://192.168.1.230:3000';
    return '$serverIp$imagePath';
  }
}
