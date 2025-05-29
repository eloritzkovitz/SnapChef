import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/notifications/app_notification.dart';
import '../utils/token_util.dart';

class BackendNotificationService {
  final String baseUrl;
  io.Socket? _socket;

  // Stream for real-time notifications
  Stream<AppNotification>? notificationStream;
  final _notificationStreamController = StreamController<AppNotification>.broadcast();

  BackendNotificationService({required this.baseUrl}) {
    notificationStream = _notificationStreamController.stream;
  }

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

  // --- Socket.IO Real-Time ---

  // Connect to Socket.IO for real-time notifications
  void connectToWebSocket(String userToken, String userId) {
    // Remove trailing slash if present
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    _socket = io.io(
      cleanBaseUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'query': {'token': userToken},
      },
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _socket!.emit('join', userId);
    });

    _socket!.on('notification', (data) {
      _notificationStreamController.add(AppNotification.fromJson(data));
    });
  }

  // Disconnect from Socket.IO
  void disconnectWebSocket() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    // Don't close the controller if you plan to reconnect later
  }
}