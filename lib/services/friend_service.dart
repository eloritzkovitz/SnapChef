import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/friend_request.dart';
import '../models/user.dart';
import '../utils/token_util.dart';

class FriendService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  // Get the current user's friends list
  Future<List<User>> getFriends() async {
    final url = Uri.parse('$baseUrl/api/users/friends');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final friendsList = data['friends'] as List<dynamic>;
      return friendsList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch friends: ${response.body}');
    }
  }

  // Get pending friend requests for the current user
  Future<List<FriendRequest>> getFriendRequests() async {
    final url = Uri.parse('$baseUrl/api/users/friends/requests');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // If your backend returns { requests: [...] }
      final requestsList = data['requests'] as List<dynamic>;
      return requestsList.map((json) => FriendRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch friend requests: ${response.body}');
    }
  }

  // Search users by query
  Future<List<User>> searchUsers(String query) async {
    final url = Uri.parse('$baseUrl/api/users?query=$query');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usersList = data as List<dynamic>;
      return usersList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users: ${response.body}');
    }
  }

  // Send a friend request
  Future<String?> sendFriendRequest(String userId) async {
    final url = Uri.parse('$baseUrl/api/users/friends/requests/$userId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['message'] as String?;
    } else {
      throw Exception('Failed to send friend request: ${response.body}');
    }
  }

  // Cancel friend request
  Future<void> cancelSentRequest(String requestId) async {
    final url = Uri.parse('$baseUrl/api/users/friends/requests/$requestId/cancel');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel friend request: ${response.body}');
    }
  }

  // Accept or decline a friend request
  Future<void> respondToRequest(String requestId, bool accept) async {
    final endpoint = accept ? 'accept' : 'decline';
    final url =
        Uri.parse('$baseUrl/api/users/friends/requests/$requestId/$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await TokenUtil.getAccessToken()}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to ${accept ? 'accept' : 'decline'} friend request: ${response.body}');
    }
  }

  // Remove a friend
  Future<void> removeFriend(String friendId) async {
    final url = Uri.parse('$baseUrl/api/users/friends/$friendId');
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
