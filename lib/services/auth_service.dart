import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/models/user.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['accessToken'], data['refreshToken'], data['_id']);
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  // Signup
  Future<Map<String, dynamic>> signup(
      String firstName, String lastName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/register'),
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

  // Google Sign-In
  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/google'),
      body: jsonEncode({'idToken': idToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['accessToken'], data['refreshToken'], data['_id']);
      return data;
    } else {
      throw Exception('Google Sign-In failed');
    }
  }

  // Get user profile
  Future<User> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final url = userId != null
        ? Uri.parse('$baseUrl/api/users/user/$userId')
        : Uri.parse('$baseUrl/api/users/user');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('401');
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode}');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String firstName,
    String lastName,
    String password,
    File? profilePicture,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final url = Uri.parse('$baseUrl/api/users/user/$userId');

    final request = http.MultipartRequest('PUT', url)
      ..headers.addAll({
        'Authorization': 'Bearer ${await getAccessToken()}',
      })
      ..fields['firstName'] = firstName
      ..fields['lastName'] = lastName
      ..fields['password'] = password;

    if (profilePicture != null) {
      final mimeType = lookupMimeType(profilePicture.path);
      if (mimeType != null && mimeType.startsWith('image/')) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
          contentType: MediaType.parse(mimeType),
        ));
      } else {
        throw Exception('Invalid file type. Only images are allowed.');
      }
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Failed to update profile: $responseBody');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/user/$userId'),
      headers: {
        'Authorization': 'Bearer ${await getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      await prefs.clear(); // Clear tokens and user data
    } else {
      throw Exception('Failed to delete account: ${response.body}');
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      await http.post(
        Uri.parse('$baseUrl/api/users/logout'),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    await prefs.clear();
  }

  // Save tokens to SharedPreferences
  Future<void> _saveTokens(
      String accessToken, String refreshToken, String _id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userId', _id);
  }

  // Get tokens from SharedPreferences
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  // Refresh tokens
  Future<void> refreshTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/users/refresh'),
      body: jsonEncode({'refreshToken': refreshToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);      
      await _saveTokens(data['accessToken'], data['refreshToken'], data['_id']);
    } else {
      // Clear tokens if refresh fails
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      throw Exception('Failed to refresh tokens: ${response.body}');
    }
  }
}
