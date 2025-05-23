import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notifications/app_notification.dart';
import '../utils/token_util.dart';

class BackendNotificationService {
  final String baseUrl;

  BackendNotificationService({required this.baseUrl});

  // Fetch all notifications for the authenticated user
  Future<List<AppNotification>> fetchNotifications() async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AppNotification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  // Create a new notification
  Future<AppNotification> createNotification(AppNotification notification) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(notification.toJson()),
    );
    if (response.statusCode == 201) {
      return AppNotification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create notification');
    }
  }

  // Update an existing notification
  Future<AppNotification> updateNotification(String id, AppNotification notification) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/notifications/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(notification.toJson()),
    );
    if (response.statusCode == 200) {
      return AppNotification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update notification');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/notifications/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete notification');
    }
  }
}