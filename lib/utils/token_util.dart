import 'package:shared_preferences/shared_preferences.dart';

class TokenUtil {
  /// Saves the access token and refresh token to shared preferences.
  static Future<void> saveTokens(String accessToken, String refreshToken, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);    
  }

  /// Retrieves the access token from shared preferences.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  /// Retrieves the refresh token from shared preferences.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  /// Clears all tokens from shared preferences.
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');    
  }
}