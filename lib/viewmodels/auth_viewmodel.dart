import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Login
  Future<void> login(String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      // Call the AuthService login method
      await _authService.login(email, password);

      // If login is successful, navigate to the main screen
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Signup
  Future<void> signup(String firstName, String lastName, String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.signup(firstName, lastName, email, password);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully!'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to the login screen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Show error message
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign-In
  Future<void> googleSignIn(String idToken, BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.googleSignIn(idToken);
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // logout
  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}