import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../providers/connectivity_provider.dart';

typedef SyncCallback = Future<void> Function();

class SyncManager {
  final ConnectivityProvider connectivityProvider;
  final List<SyncCallback> _callbacks = [];
  final AuthService _authService = AuthService();

  SyncManager(this.connectivityProvider) {
    connectivityProvider.addListener(_onConnectivityChanged);
  }

  /// Registers a callback to be called when connectivity changes to online.
  void register(SyncCallback callback) {
    _callbacks.add(callback);
  }

  /// Unregisters a callback so it will no longer be called on connectivity changes.
  void unregister(SyncCallback callback) {
    _callbacks.remove(callback);
  }

  /// Ensures the user is authenticated before performing any sync operations.
  Future<bool> _isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');    
    return accessToken != null && refreshToken != null;
  }

  /// Ensures the user is authenticated, refreshing tokens if necessary.
  Future<void> _ensureAuthenticated() async {
    if (!await _isAuthenticated()) {
      // Try to refresh tokens if possible
      try {
        await _authService.refreshTokens();
      } catch (_) {        
      }
    }
  }

  /// Called when connectivity changes to online.
  void _onConnectivityChanged() async {
    if (!connectivityProvider.isOffline) {
      await _ensureAuthenticated();
      if (await _isAuthenticated()) {
        for (final cb in _callbacks) {
          await cb();
        }
      }
    }
  }

  /// Triggers a sync immediately if currently online.
  Future<void> triggerSyncIfOnline() async {
    if (!connectivityProvider.isOffline) {
      await _ensureAuthenticated();
      if (await _isAuthenticated()) {
        for (final cb in _callbacks) {
          await cb();
        }
      }
    }
  }

  /// Disposes the sync manager by removing the connectivity listener.
  void dispose() {
    connectivityProvider.removeListener(_onConnectivityChanged);
  }
}