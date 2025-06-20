import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';

class ConnectivityProvider extends ChangeNotifier with WidgetsBindingObserver {
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  final Connectivity _connectivity;
  Timer? _timer;
  AppLifecycleState _appState = AppLifecycleState.resumed;

  ConnectivityProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    WidgetsBinding.instance.addObserver(this);
    _connectivity.onConnectivityChanged.listen((result) {
      checkInternetAndServer();
    });
    checkInternetAndServer();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkInternetAndServer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appState = state;
    if (state == AppLifecycleState.resumed) {
      checkInternetAndServer();
    }
  }  

  /// Checks internet connectivity and server availability.
  /// Updates [_isOffline] and notifies listeners if the status changes.
  Future<void> checkInternetAndServer() async {
    if (_appState != AppLifecycleState.resumed) return;

    bool offline = false;

    // First, check if any network is available
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      offline = true;
    } else {
      // Try to reach the server
      final serverIp = dotenv.env['SERVER_IP'];
      if (serverIp == null) {
        offline = true;
      } else {
        try {
          final response = await http
              .get(Uri.parse('$serverIp/health'))
              .timeout(const Duration(seconds: 3));
          if (response.statusCode != 200) {
            offline = true;
            log("Server is not reachable, status code: ${response.statusCode}");
          }
        } catch (_) {
          offline = true;
          log("Failed to reach server at $serverIp");
        }
      }
    }

    if (_isOffline != offline) {
      _isOffline = offline;

      if (!_isOffline) {        
        try {         
          await GetIt.I<AuthViewModel>().refreshTokens();         
          await GetIt.I<SyncProvider>().syncPendingActions();          
        } catch (e) {
          log('Failed to refresh tokens or sync actions: $e');          
        }
      }

      notifyListeners();
    }
  }
}