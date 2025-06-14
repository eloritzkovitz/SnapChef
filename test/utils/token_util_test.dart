import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/utils/token_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenUtil', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and get tokens', () async {
      await TokenUtil.saveTokens('access', 'refresh', 'user1');
      expect(await TokenUtil.getAccessToken(), 'access');
      expect(await TokenUtil.getRefreshToken(), 'refresh');
    });

    test('clearTokens removes tokens', () async {
      await TokenUtil.saveTokens('access', 'refresh', 'user1');
      await TokenUtil.clearTokens();
      expect(await TokenUtil.getAccessToken(), isNull);
      expect(await TokenUtil.getRefreshToken(), isNull);
    });
  });
}