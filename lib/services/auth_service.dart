import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/token_util.dart';

class AuthService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  // Google Sign-In
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
      throw Exception('Google Sign-In failed');
    }
  }

  // Login
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
      throw Exception('Login failed');
    }
  }

  // Signup
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
      throw Exception('Signup failed');
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    await prefs.clear();
  }

  // Refresh tokens
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

  // Send OTP for email verification
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

  // Resend OTP
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
}
