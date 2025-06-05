import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityProvider extends ChangeNotifier {
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  final Connectivity _connectivity = Connectivity();
  Timer? _timer;

  ConnectivityProvider() {
    _connectivity.onConnectivityChanged.listen((result) {
      _checkInternetAndServer();
    });
    _checkInternetAndServer();

    // Poll the server every 10 seconds (adjust as needed)
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkInternetAndServer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkInternetAndServer() async {
    bool offline = false;

    // First, check if any network is available
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      offline = true;
    } else {
      // Try to reach your server using SERVER_IP from .env
      final serverIp = dotenv.env['SERVER_IP'];
      if (serverIp == null) {
        offline = true;
      } else {
        try {
          final response = await http
              .get(Uri.parse('$serverIp/api-docs'))
              .timeout(const Duration(seconds: 3));             
          if (response.statusCode != 200) {
            offline = true;
          }
        } catch (_) {
          offline = true;
        }
      }
    }

    if (_isOffline != offline) {
      _isOffline = offline;      
      notifyListeners();
    }
  }
}