import '../providers/connectivity_provider.dart';

typedef SyncCallback = Future<void> Function();

class SyncManager {
  final ConnectivityProvider connectivityProvider;
  final List<SyncCallback> _callbacks = [];

  SyncManager(this.connectivityProvider) {
    connectivityProvider.addListener(_onConnectivityChanged);
  }

  void register(SyncCallback callback) {
    _callbacks.add(callback);
  }

  void unregister(SyncCallback callback) {
    _callbacks.remove(callback);
  }

  void _onConnectivityChanged() {
    if (!connectivityProvider.isOffline) {
      for (final cb in _callbacks) {
        cb();
      }
    }
  }

  void dispose() {
    connectivityProvider.removeListener(_onConnectivityChanged);
  }
}