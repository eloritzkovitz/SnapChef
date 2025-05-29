import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/notifications/app_notification.dart';
import '../utils/token_util.dart';

class BackendNotificationService {
  final String baseUrl;
  WebSocketChannel? _channel;

  // Stream for real-time notifications
  Stream<AppNotification>? notificationStream;

  BackendNotificationService({required this.baseUrl});

  // --- HTTP CRUD ---

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

  // --- WebSocket Real-Time ---

  // Connect to WebSocket for real-time notifications
  void connectToWebSocket(String userToken) {    
    final wsUrl = '${baseUrl.replaceFirst('http', 'ws')}/ws/notifications?token=$userToken';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    notificationStream = _channel!.stream.map((event) {
      final data = jsonDecode(event);
      return AppNotification.fromJson(data);
    });
  }

  // Disconnect from WebSocket
  void disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
    notificationStream = null;
  }
}