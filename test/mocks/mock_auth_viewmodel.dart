import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';

class MockAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool isLoading = false;

  bool _isLoggingOut = false;

  @override
  bool get isLoggingOut => _isLoggingOut;

  @override
  set isLoggingOut(bool value) {
    _isLoggingOut = value;
    notifyListeners();
  }

  @override
  void setLoggingOut(bool value) {
    isLoggingOut = value;
  }

  @override
  Future<void> googleSignIn(BuildContext context, Function fetchUserData) async {}

  @override
  Future<void> login(String email, String password, BuildContext context, Function fetchUserData) async {}

  @override
  Future<void> logout(BuildContext context) async {}

  @override
  Future<void> refreshTokens() async {}

  @override
  Future<bool> signup(String first, String last, String email, String pass, BuildContext context) async => true;

  @override
  Future<void> requestPasswordReset(String email, BuildContext context) async {}

  @override
  Future<void> verifyOTP(String email, String otp, BuildContext context) async {}

  @override
  Future<void> resendOTP(String email) async {}

  @override
  Future<void> confirmPasswordReset(String email, String otp, String password, BuildContext context) async {}  
}