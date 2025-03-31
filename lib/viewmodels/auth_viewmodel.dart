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
      await _authService.login(email, password);
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Signup
  Future<void> signup(String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.signup(email, password);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
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