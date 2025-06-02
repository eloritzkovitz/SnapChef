import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/models/user.dart';
import '../utils/token_util.dart';

class UserService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  // Get user profile using /me endpoint
  Future<User> getUserData() async {
    final url = Uri.parse('$baseUrl/api/users/me');

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
  Future<Map<String, dynamic>> updateUser(
    String firstName,
    String lastName,
    String password,
    File? profilePicture,
  ) async {
    final url = Uri.parse('$baseUrl/api/users/me');

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
    required Map<String, bool>? notificationPreferences,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse('$baseUrl/api/users/me/preferences');
    final Map<String, dynamic> body = {
      'allergies': allergies,
      'dietaryPreferences': dietaryPreferences,
    };
    if (notificationPreferences != null) {
      body['notificationPreferences'] = notificationPreferences;
    }

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update preferences: ${response.body}');
    }
  }

  // Update the user's FCM token
  Future<void> updateFcmToken(String token) async {
    final url = Uri.parse('$baseUrl/api/users/me/fcm-token');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fcmToken': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update FCM token: ${response.body}');
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/me'),
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

  // Fetch user profile by userId
  Future<User> getUserProfile(String userId) async {
    final url = Uri.parse('$baseUrl/api/users/$userId');

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

  // Fetch user statistics
  Future<Map<String, dynamic>> getUserStats({String? userId}) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/stats');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception('401');
    } else {
      throw Exception('Failed to fetch user stats: ${response.statusCode}');
    }
  }
}
