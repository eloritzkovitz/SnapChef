import 'dart:io';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../models/preferences.dart';
import '../utils/ui_util.dart';

class UserViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();  
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool isLoggingOut = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;

  String? get fridgeId => _user?.fridgeId;
  String? get cookbookId => _user?.cookbookId;  

  // Fetch user data
  Future<void> fetchUserData() async {
    try {
      final userProfile = await _userService.getUserData();
      _user = userProfile;
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('401')) {
        try {
          await _authService.refreshTokens();
          final userProfile = await _userService.getUserData();
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
  Future<void> updateUser({
    required String firstName,
    required String lastName,
    String? password,
    File? profilePicture,
  }) async {
    _setLoading(true);
    try {
      // Call the AuthService to update the user profile
      final updatedData = await _userService.updateUser(
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

  // Update User Preferences
  Future<void> updateUserPreferences({
    required List<String> allergies,
    required Map<String, bool> dietaryPreferences,
  }) async {
    if (_user == null) throw Exception('User not loaded');
    await _userService.updateUserPreferences(
      allergies: allergies,
      dietaryPreferences: dietaryPreferences,
    );

    // Update the local user object with new preferences
    _user = _user!.copyWith(
      preferences: Preferences(
        allergies: allergies,
        dietaryPreferences: dietaryPreferences,
      ),
    );
    notifyListeners();
  }  

  // Delete User Account
  Future<void> deleteUser(BuildContext context) async {
    _setLoading(true);
    try {
      await _userService.deleteUser();
      _user = null; // Clear the user data on account deletion
      notifyListeners(); // Notify listeners to update the UI
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      UIUtil.showError(context, e.toString());
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

  // Fetch another user's profile by userId
  Future<User?> fetchUserProfile(String userId) async {
    try {
      final userProfile = await _userService.getUserProfile(userId);
      return userProfile;
    } catch (e) {
      print('Error fetching user profile for $userId: $e');
      return null;
    }
  }
}
