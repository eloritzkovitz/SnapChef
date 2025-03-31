import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/models/user.dart';

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
  Future<Map<String, dynamic>> signup(String firstName, String lastName, String email, String password) async {
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

  // Refresh tokens
  Future<Map<String, dynamic>> refreshTokens() async {
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
      return data;
    } else {
      throw Exception('Token refresh failed');
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
    } else {      
      throw Exception('Failed to fetch user profile');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String firstName, String lastName, String email, File? profilePicture) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final url = Uri.parse('$baseUrl/api/users/user/$userId');
    print('Updating user profile at URL: $url'); // Debug log

    final request = http.MultipartRequest('PUT', url)
      ..headers.addAll({
        'Authorization': 'Bearer ${await getAccessToken()}',
      })
      ..fields['firstName'] = firstName
      ..fields['lastName'] = lastName
      ..fields['email'] = email;
 
    if (profilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        profilePicture.path,
      ));
    }

    final response = await request.send();    

    print('Response status code: ${response.statusCode}'); // Debug log
    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody'); // Debug log
      throw Exception('Failed to update profile: $responseBody');
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
  Future<void> _saveTokens(String accessToken, String refreshToken, String _id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userId', _id);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }
}