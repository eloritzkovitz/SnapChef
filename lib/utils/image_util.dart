import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUtil {
  /// Returns the full URL of the image based on the provided image path.
  /// Defaults to a local asset path if the image path is null or empty.
  String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Return a default asset path for missing images
      return 'assets/images/default_offline_image.png';
    }
    if (imageUrl.startsWith('http')) return imageUrl;
    final serverUrl = dotenv.env['SERVER_IP'] ?? '';
    return '$serverUrl$imageUrl';
  }
}
