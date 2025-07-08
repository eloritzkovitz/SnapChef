import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';

class MockAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool isLoading = false;

  @override
  String? errorMessage;
  @override
  String? infoMessage;
  @override
  bool otpVerified = false;  
  
  bool _isLoggingOut = false;

  bool shouldFailOnVerify = false;
  bool shouldFailOnResend = false;
  bool shouldFailOnRequestReset = false;
  bool shouldFailOnConfirmReset = false; 

  @override
  bool get isLoggingOut => _isLoggingOut;

  @override
  void setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  @override
  void clearError() {
    errorMessage = null;
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
  Future<void> googleSignIn(
      BuildContext context, Future<void> Function() fetchUserProfile) async {}

  @override
  Future<void> login(String email, String password, BuildContext context,
      Future<void> Function() fetchUserProfile) async {}

  @override
  Future<void> logout(BuildContext context) async {}

  @override
  Future<void> refreshTokens() async {}

  @override
  Future<bool> signup(String firstName, String lastName, String email,
          String password, BuildContext context) async =>
      true;

  @override
  Future<void> requestPasswordReset(String email, BuildContext context) async {
    if (shouldFailOnRequestReset) {
      errorMessage = 'Failed to resend code. Please try again.';
      notifyListeners();
      return;
    }
    errorMessage = null;
    infoMessage = 'Reset code sent! Please check your email.';
    notifyListeners();
  }

  @override
  Future<void> verifyOTP(String email, String otp, BuildContext context) async {
    if (shouldFailOnVerify) {
      errorMessage = 'Invalid OTP. Please try again.';
      otpVerified = false;
      notifyListeners();
      return;
    }
    errorMessage = null;
    infoMessage = 'Email verified! Please log in.';
    otpVerified = true;
    notifyListeners();
  }

  @override
  Future<bool> resendOTP(String email) async {
    if (shouldFailOnResend) {
      errorMessage = 'Failed to resend OTP. Please try again.';
      notifyListeners();
      return false;
    }
    errorMessage = null;
    infoMessage = 'OTP resent! Please check your email.';
    notifyListeners();
    return true;
  }

  @override
  Future<void> confirmPasswordReset(String email, String otp,
      String newPassword, BuildContext context) async {
    if (shouldFailOnConfirmReset) {
      errorMessage = 'Failed to reset password. Please try again.';
      notifyListeners();
      return;
    }
    errorMessage = null;
    infoMessage = 'Password reset successful! Please log in.';
    notifyListeners();
  }
}
