import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  User? _user; // Add a User object to store the profile data

  bool get isLoading => _isLoading;
  User? get user => _user; // Expose the user data to the UI

  // Login
  Future<void> login(String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      // Call the AuthService login method
      await _authService.login(email, password);

      // Fetch the user profile after login
      await fetchUserProfile();

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

  // Fetch User Profile
  Future<void> fetchUserProfile() async {
    _setLoading(true);
    try {
      print('Fetching user profile...');
      final userProfile = await _authService.getUserProfile();      
 
      _user = userProfile;
      print(userProfile);
      notifyListeners();
    } catch (e) {
      print('Error fetching user profile: $e');
      _user = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign-In
  Future<void> googleSignIn(String idToken, BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.googleSignIn(idToken);

      // Fetch the user profile after Google Sign-In
      await fetchUserProfile();

      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null; // Clear the user data on logout
      notifyListeners(); // Notify listeners to update the UI
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