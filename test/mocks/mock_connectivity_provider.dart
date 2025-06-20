import 'package:flutter/material.dart';
import 'package:snapchef/providers/connectivity_provider.dart';

class MockConnectivityProvider extends ChangeNotifier implements ConnectivityProvider {
  bool _isOffline;
  MockConnectivityProvider({bool isOffline = false}) : _isOffline = isOffline;

  @override
  bool get isOffline => _isOffline;

  set isOffline(bool value) {
    if (_isOffline != value) {
      _isOffline = value;
      notifyListeners();
    }
  }

  @override
  Future<void> checkInternetAndServer({bool offline = false}) async {
    _isOffline = offline;
    notifyListeners();
  }

  // Satisfy all other abstract/interface members if needed
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}