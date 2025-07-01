import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';

class MockAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool isLoading = false;

  String? _errorMessage;
  bool _isLoggingOut = false;

  @override
  String? get errorMessage => _errorMessage;

  @override
  bool get isLoggingOut => _isLoggingOut;

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
  void setLoggingOut(bool value) {
    _isLoggingOut = value;
    notifyListeners();
  }

  @override
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void clear() {
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> googleSignIn(BuildContext context, Future<void> Function() fetchUserProfile) async {}

  @override
  Future<void> login(String email, String password, BuildContext context, Future<void> Function() fetchUserProfile) async {}

  @override
  Future<void> logout(BuildContext context) async {}

  @override
  Future<void> refreshTokens() async {}

  @override
  Future<bool> signup(String firstName, String lastName, String email, String password, BuildContext context) async => true;

  @override
  Future<void> requestPasswordReset(String email, BuildContext context) async {}

  @override
  Future<void> verifyOTP(String email, String otp, BuildContext context) async {}

  @override
  Future<void> resendOTP(String email) async {}

  @override
  Future<void> confirmPasswordReset(String email, String otp, String newPassword, BuildContext context) async {}
}