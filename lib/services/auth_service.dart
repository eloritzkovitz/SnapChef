import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/token_util.dart';

class AuthService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  /// Logs in a user with Google Sign-In using the provided ID token.
  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/google'),
      body: jsonEncode({'idToken': idToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenUtil.saveTokens(
          data['accessToken'], data['refreshToken'], data['_id']);
      return data;
    } else {
      String errorMsg = 'Google Sign-In failed';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          errorMsg = 'Google Sign-In failed: ${data['message']}';
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  /// Logs in a user with email and password.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenUtil.saveTokens(
          data['accessToken'], data['refreshToken'], data['_id']);
      return data;
    } else {
      String errorMsg = 'Login failed';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'];
        }
      } catch (_) {        
        if (response.body.isNotEmpty) {
          errorMsg = response.body;
        }
      }
      throw Exception(errorMsg);
    }
  }

  /// Signs up a new user with the provided details.
  Future<Map<String, dynamic>> signup(
      String firstName, String lastName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      String errorMsg = 'Signup failed';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          errorMsg = 'Signup failed: ${data['message']}';
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  /// Logs the user out.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        String errorMsg = 'Logout failed';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] != null) {
            errorMsg = 'Logout failed: ${data['message']}';
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    }

    await prefs.clear();
  }

  /// Refreshes the access token using the refresh token.
  /// If the refresh token is invalid or expired, it clears the tokens.
  Future<void> refreshTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      body: jsonEncode({'refreshToken': refreshToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenUtil.saveTokens(
          data['accessToken'], data['refreshToken'], data['_id']);
    } else {
      // Clear tokens if refresh fails
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      throw Exception('Failed to refresh tokens: ${response.body}');
    }
  }

  /// Sends an OTP to the user's email for verification.
  Future<void> verifyOTP(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      body: jsonEncode({'email': email, 'otp': otp}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('OTP verification failed: ${response.body}');
    }
  }

  /// Resends the OTP to the user's email.
  Future<void> resendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to resend OTP: ${response.body}');
    }
  }

  /// Requests a password reset link to be sent to the user's email.
  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/request-password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to request password reset: ${response.body}');
    }
  }

  /// Confirms the password reset using the provided OTP and new password.
  Future<void> confirmPasswordReset(
      String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/confirm-password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reset password: ${response.body}');
    }
  }
}
