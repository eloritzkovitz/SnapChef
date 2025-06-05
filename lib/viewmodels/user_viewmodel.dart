import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/user_service.dart';
import '../models/user.dart' as model;
import '../models/preferences.dart';
import '../utils/ui_util.dart';
import '../database/app_database.dart' as db;

class UserViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final db.AppDatabase database;

  UserViewModel(BuildContext context)
      : database = Provider.of<db.AppDatabase>(context, listen: false);

  bool _isLoading = false;
  bool isLoggingOut = false;
  model.User? _user;
  Map<String, dynamic>? _userStats;

  bool get isLoading => _isLoading;
  model.User? get user => _user;

  String? get fridgeId => _user?.fridgeId;
  String? get cookbookId => _user?.cookbookId;
  Map<String, dynamic>? get userStats => _userStats;
  List<model.User> get friends => _user?.friends ?? [];

  // Fetch user data (including friends) and store locally
  Future<void> fetchUserData() async {
    try {
      final userProfile = await _userService.getUserData();
      _user = userProfile;
      notifyListeners();

      // Store user in local DB and SharedPreferences
      await _storeUserLocally(userProfile);

      // Update FCM token after fetching user data
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await updateFcmToken(fcmToken);
    } catch (e) {
      if (e.toString().contains('401')) {
        try {
          await _authService.refreshTokens();
          final userProfile = await _userService.getUserData();
          _user = userProfile;
          notifyListeners();

          // Store user in local DB and SharedPreferences
          await _storeUserLocally(userProfile);

          // Update FCM token after refreshing user data
          final fcmToken = await FirebaseMessaging.instance.getToken();
          await updateFcmToken(fcmToken);
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

  Future<void> _storeUserLocally(model.User user) async {  

    // Serialize preferences if needed
    String? preferencesJson;
    if (user.preferences != null) {
      preferencesJson = Preferences.toJsonString(user.preferences!);
    }

    // Create db.User instance with all relevant fields
    final dbUser = db.User(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      fridgeId: user.fridgeId,
      cookbookId: user.cookbookId,
      fcmToken: user.fcmToken,
      profilePicture: user.profilePicture,
      preferencesJson:
          preferencesJson, 
    );

    await database.userDao.insertUser(dbUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
  }

  // Get friends list
  Future<List<model.User>> getFriends() async {
    await fetchUserData();
    return _user?.friends ?? [];
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
      final updatedData = await _userService.updateUser(
        firstName,
        lastName,
        password ?? '',
        profilePicture,
      );
      final newProfilePicture = updatedData['profilePicture'];
      if (_user != null) {
        _user = _user!.copyWith(
          firstName: firstName,
          lastName: lastName,
          password: password ?? _user!.password,
          profilePicture: profilePicture != null
              ? newProfilePicture ?? _user!.profilePicture
              : _user!.profilePicture,
        );
        notifyListeners();

        // Store updated user locally
        await _storeUserLocally(_user!);
      }
    } catch (e) {
      throw Exception('Failed to update profile');
    } finally {
      _setLoading(false);
    }
  }

  // Update User Preferences
  Future<void> updateUserPreferences({
    List<String>? allergies,
    Map<String, bool>? dietaryPreferences,
    Map<String, bool>? notificationPreferences,
  }) async {
    if (_user == null) throw Exception('User not loaded');

    final updatedAllergies = allergies ?? _user!.preferences?.allergies ?? [];
    final updatedDietary =
        dietaryPreferences ?? _user!.preferences?.dietaryPreferences ?? {};
    final updatedNotifications = notificationPreferences ??
        _user!.preferences?.notificationPreferences ??
        {};

    await _userService.updateUserPreferences(
      allergies: updatedAllergies,
      dietaryPreferences: updatedDietary,
      notificationPreferences: updatedNotifications,
    );

    _user = _user!.copyWith(
      preferences: Preferences(
        allergies: updatedAllergies,
        dietaryPreferences: updatedDietary,
        notificationPreferences: updatedNotifications,
      ),
    );
    notifyListeners();

    // Store updated user locally
    await _storeUserLocally(_user!);
  }

  // Update FCM Token
  Future<void> updateFcmToken(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      await _userService.updateFcmToken(token);
      if (_user != null) {
        _user = _user!.copyWith(fcmToken: token);
        notifyListeners();

        // Store updated user locally
        await _storeUserLocally(_user!);
      }
    } catch (e) {
      throw Exception('Failed to update FCM token: ${e.toString()}');
    }
  }

  // Listen for FCM token refresh and update backend
  void listenForFcmTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await updateFcmToken(newToken);
    });
  }

  // Delete User Account
  Future<void> deleteUser(BuildContext context) async {
    _setLoading(true);
    try {
      await _userService.deleteUser();
      _user = null;
      notifyListeners();

      // Remove user from local DB and SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await database.userDao.deleteUser(_user?.id ?? '');

      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (context.mounted) UIUtil.showError(context, e.toString());
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
  Future<model.User?> fetchUserProfile(String userId) async {
    try {
      final userProfile = await _userService.getUserProfile(userId);
      return userProfile;
    } catch (e) {
      return null;
    }
  }

  // Fetch user statistics
  Future<void> fetchUserStats({String? userId}) async {
    try {
      final stats = await _userService.getUserStats(userId: userId);
      _userStats = stats;
      notifyListeners();
    } catch (e) {
      _userStats = null;
      notifyListeners();
      rethrow;
    }
  }

  // Remove friend
  Future<void> removeFriend(String friendId) async {
    await FriendService().removeFriend(friendId);
    // Optionally, refresh the user data or friends list
    await fetchUserData();
  }
}
