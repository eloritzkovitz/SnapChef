import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  final _userStatsController = StreamController<Map<String, dynamic>>.broadcast();
  final _friendUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get userStatsStream => _userStatsController.stream;
  Stream<Map<String, dynamic>> get friendUpdateStream => _friendUpdateController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  /// Connects to the WebSocket server with the provided user token.
  /// The user token is used for authentication and should be passed as a Bearer token in the headers.
  void connect(String userToken) {
    if (_socket != null) return;
    _socket = io.io('YOUR_SERVER_URL', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $userToken'},
    });
    _socket!.connect();

    _socket!.on('userStatsUpdate', (data) {
      _userStatsController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('friendUpdate', (data) {
      _friendUpdateController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('notification', (data) {
      _notificationController.add(Map<String, dynamic>.from(data));
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