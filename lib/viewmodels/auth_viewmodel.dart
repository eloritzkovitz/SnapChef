import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../../utils/ui_util.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool isLoggingOut = false;

  bool get isLoading => _isLoading;

  // Google Sign-In
  Future<void> googleSignIn(
    BuildContext context,
    Future<void> Function() fetchUserProfile,
  ) async {
    _setLoading(true);
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Retrieve the idToken
        final idToken = googleAuth.idToken;

        if (idToken != null) {
          // Send the idToken to your backend for authentication
          await _authService.googleSignIn(idToken);

          // Fetch the user profile after successful sign-in using UserViewModel
          await fetchUserProfile();

          // Navigate to the main screen
          if (context.mounted) Navigator.pushReplacementNamed(context, '/main');
        } else {
          throw Exception('Failed to retrieve Google ID token');
        }
      }
    } catch (e) {
      if (context.mounted) {
        UIUtil.showError(context, 'Google Sign-In failed: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<void> login(
    String email,
    String password,
    BuildContext context,
    Future<void> Function() fetchUserProfile,
  ) async {
    _setLoading(true);
    try {
      // Call the AuthService login method
      await _authService.login(email, password);

      // Fetch the user profile after login using UserViewModel
      await fetchUserProfile();

      // If login is successful, navigate to the main screen
      if (context.mounted) Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      if (context.mounted) UIUtil.showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Signup
  Future<void> signup(String firstName, String lastName, String email,
      String password, BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.signup(firstName, lastName, email, password);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Navigate to the login screen
      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Show error message
      if (context.mounted) UIUtil.showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    try {
      await _authService.logout();
      notifyListeners();
      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (context.mounted) UIUtil.showError(context, e.toString());
    }
  }

  // Refresh Tokens
  Future<void> refreshTokens() async {
    try {
      await _authService.refreshTokens();
    } catch (e) {
      throw Exception('Failed to refresh tokens: $e');
    }
  }

  // Set the loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Set the logging out state
  void setLoggingOut(bool value) {
    isLoggingOut = value;
    notifyListeners();
  }

  // Verify OTP
  Future<void> verifyOTP(String email, String otp, BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.verifyOTP(email, otp);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified! Please log in.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) UIUtil.showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<void> resendOTP(String email) async {
    _setLoading(true);
    try {
      await _authService.resendOTP(email);
    } finally {
      _setLoading(false);
    }
  }
}
