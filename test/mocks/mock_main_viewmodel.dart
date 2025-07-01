import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';

class MockMainViewModel extends ChangeNotifier implements MainViewModel {
  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _isLoggingOut = false;
  String? _errorMessage;

  @override
  int get selectedIndex => _selectedIndex;

  @override
  Widget get currentScreen => const SizedBox.shrink();

  @override
  String get appBarTitle => 'Mock Title';

  @override
  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // --- BaseViewModel required members ---
  @override
  bool get isLoading => _isLoading;

  @override
  bool get isLoggingOut => _isLoggingOut;

  @override
  String? get errorMessage => _errorMessage;

  @override
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void setLoggingOut(bool value) {
    _isLoggingOut = value;
    notifyListeners();
  }

  @override
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void clear() {
    _isLoading = false;
    _isLoggingOut = false;
    _errorMessage = null;
    notifyListeners();
  }
}