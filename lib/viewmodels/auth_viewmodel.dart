import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool isLoggingOut = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;

  String? get fridgeId => _user?.fridgeId;
  String? get cookbookId => _user?.cookbookId;

  // Login
  Future<void> login(
      String email, String password, BuildContext context) async {
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
  Future<void> signup(String firstName, String lastName, String email,
      String password, BuildContext context) async {
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

      // Fetch the user profile after Google Sign-In
      await fetchUserProfile();

      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch User Profile
  Future<void> fetchUserProfile() async {
    try {      
      final userProfile = await _authService.getUserProfile();
      _user = userProfile;      
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('401')) {
        // If the error is due to an expired token, attempt to refresh the token        
        try {
          await _authService.refreshTokens();          
          // Retry fetching the user profile with the new access token
          final userProfile = await _authService.getUserProfile();
          _user = userProfile;          
          notifyListeners();
        } catch (refreshError) {          
          _user = null;
          notifyListeners();
          throw Exception('Failed to refresh token and fetch user profile');
        }
      } else {        
        _user = null;
        notifyListeners();
        throw Exception('Failed to fetch user profile');
      }
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    File? profilePicture,
  }) async {
    //_setLoading(true);
    try {
      // Call the AuthService to update the user profile
      final updatedData = await _authService.updateUserProfile(
        firstName,
        lastName,
        email,
        profilePicture,
      );

      // Extract the new profile picture relative path from the response
      final newProfilePicture = updatedData['profilePicture'];

      // Update the local user object
      if (_user != null) {
        _user = User(
          firstName: firstName,
          lastName: lastName,
          email: email,
          profilePicture: profilePicture !=
                  null // Check if a new profile picture was provided
              ? newProfilePicture ?? _user!.profilePicture
              : _user!.profilePicture,
          fridgeId: _user!.fridgeId,
          cookbookId: _user!.cookbookId,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile: $e');
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return an empty string or a default image URL if the path is null
    }
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://192.168.1.230:3000';
    return '$serverIp$imagePath';
  }
}
