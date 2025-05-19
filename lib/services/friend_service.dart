import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../utils/token_util.dart';

class FriendService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  // Get the current user's friends list
  Future<List<Friend>> getFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final url = Uri.parse('$baseUrl/api/users/$userId/friends');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => Friend.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch friends: ${response.body}');
    }
  }  

  // Send a friend request
  Future<void> sendFriendRequest(String friendId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final url = Uri.parse('$baseUrl/api/users/$userId/friends/requests');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
      body: jsonEncode({'friendId': friendId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send friend request: ${response.body}');
    }
  }

  // Remove a friend
  Future<void> removeFriend(String friendId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final url = Uri.parse('$baseUrl/api/users/$userId/friends/$friendId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove friend: ${response.body}');
    }
  }
}
