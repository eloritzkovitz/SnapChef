import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/token_util.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  final _userStatsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _friendUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get userStatsStream =>
      _userStatsController.stream;
  Stream<Map<String, dynamic>> get friendUpdateStream =>
      _friendUpdateController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  /// Connects to the WebSocket server with the provided user token.
  /// The user token is used for authentication and should be passed as a Bearer token in the headers.
  Future<void> connect(String userId) async {
    debugPrint('Attempting to connect socket for $userId');
    if (_socket != null) return;

    // Get the base URL from .env
    String? baseUrl = dotenv.env['SERVER_IP'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('SERVER_IP is not set in .env');
    }
    // Get the user token from TokenUtil
    final userToken = await TokenUtil.getAccessToken();
    debugPrint('Connecting to socket server: $baseUrl');

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'token': userToken})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _socket!.emit('join', userId);
      debugPrint('Socket connected: $userId');
    });
    _socket!.onConnectError((err) {
      debugPrint('Socket connection error: $err');
    });
    _socket!.onError((err) {
      debugPrint('Socket general error: $err');
    });
    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
    });
    _socket!.on('userStatsUpdate', (data) {
      _userStatsController.add(Map<String, dynamic>.from(data));
      debugPrint('User stats updated: $data');
    });
    _socket!.on('friendUpdate', (data) {
      _friendUpdateController.add(Map<String, dynamic>.from(data));
      debugPrint('Friend update received: $data');
    });
    _socket!.on('notification', (data) {
      _notificationController.add(Map<String, dynamic>.from(data));
      debugPrint('Notification received: $data');
    });
  }

  /// Disconnects from the WebSocket server.
  /// This method should be called when the user logs out or when the app is disposed.
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Disposes the service and closes the streams.
  /// This should be called when the app is disposed to prevent memory leaks.
  void dispose() {
    _userStatsController.close();
    _notificationController.close();
    disconnect();
  }
}
