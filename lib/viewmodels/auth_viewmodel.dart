import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
  Future<void> googleSignIn(BuildContext context) async {
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

          // Fetch the user profile after successful sign-in
          await fetchUserProfile();

          // Navigate to the main screen
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          throw Exception('Failed to retrieve Google ID token');
        }
      }
    } catch (e) {
      _showError(context, 'Google Sign-In failed: $e');
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
        try {
          await refreshTokens();
          final userProfile = await _authService.getUserProfile();
          _user = userProfile;
          notifyListeners();
        } catch (refreshError) {
          _user = null;
          notifyListeners();
          rethrow;
        }
      } else {
        _user = null;
        notifyListeners();
        rethrow;
      }
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    String? password,
    File? profilePicture,
  }) async {
    _setLoading(true);
    try {
      // Call the AuthService to update the user profile
      final updatedData = await _authService.updateUserProfile(
        firstName,
        lastName,
        password ?? '',
        profilePicture,
      );

      // Extract the new profile picture relative path from the response
      final newProfilePicture = updatedData['profilePicture'];

      // Update the local user object
      if (_user != null) {
        _user = _user!.copyWith(
          firstName: firstName,
          lastName: lastName,
          password: password ??
              _user!.password, // Keep the current password if not updated
          profilePicture: profilePicture != null
              ? newProfilePicture ?? _user!.profilePicture
              : _user!.profilePicture, // Update profile picture if provided
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile');
    } finally {
      _setLoading(false);
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

  // Update User Preferences
  Future<void> updateUserPreferences({
    required String allergies,
    required Map<String, bool> dietaryPreferences,
  }) async {
    // Update the user's preferences in the backend
    try {
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Delete User Account
  Future<void> deleteAccount(BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.deleteAccount();
      _user = null; // Clear the user data on account deletion
      notifyListeners(); // Notify listeners to update the UI
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    try {
      await _authService.logout();
      _user = null; // Clear the user data on logout
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _showError(context, e.toString());
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
