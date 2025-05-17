import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/models/user.dart';
import '../utils/token_util.dart';

class AuthService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';  

  // Get user profile
  Future<User> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final url = userId != null
        ? Uri.parse('$baseUrl/api/users/$userId')
        : Uri.parse('$baseUrl/api/users');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
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

    final url = Uri.parse('$baseUrl/api/users/$userId');

    final request = http.MultipartRequest('PUT', url)
      ..headers.addAll({
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
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

  // Update user preferences
  Future<void> updateUserPreferences({    
    required List<String> allergies,
    required Map<String, bool> dietaryPreferences,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse('$baseUrl/api/users/$userId/preferences');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'allergies': allergies,
        'dietaryPreferences': dietaryPreferences,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update preferences: ${response.body}');
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
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      await prefs.clear(); // Clear tokens and user data
    } else {
      throw Exception('Failed to delete account: ${response.body}');
    }
  }
}
