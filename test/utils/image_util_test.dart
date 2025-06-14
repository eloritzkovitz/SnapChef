import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/utils/image_util.dart';

void main() {
  group('ImageUtil', () {
    final util = ImageUtil();

    test('returns default asset for null or empty', () {
      expect(util.getFullImageUrl(null), contains('default_offline_image.png'));
      expect(util.getFullImageUrl(''), contains('default_offline_image.png'));
    });

    test('returns http url as is', () {
      const url = 'http://example.com/image.png';
      expect(util.getFullImageUrl(url), url);
    });

    test('returns server url for relative path', () {      
      const relative = '/images/test.png';
      final result = util.getFullImageUrl(relative);
      expect(result, contains(relative));
    });
  });
}