import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as model;
import '../models/preferences.dart';
import '../database/app_database.dart' as db;
import '../services/user_service.dart';

class UserRepository {
  final db.AppDatabase database = GetIt.I<db.AppDatabase>();
  final UserService userService = GetIt.I<UserService>();

  // --- Local DB Methods ---

  Future<model.User?> fetchUserLocal({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final id = userId ?? prefs.getString('userId');
    db.User? localUser;
    if (id != null && id.isNotEmpty) {
      localUser = await database.userDao.getUserById(id);
    } else {
      final users = await database.userDao.getAllUsers();
      localUser = users.isNotEmpty ? users.first : null;
    }
    if (localUser != null) {
      return model.User.fromDb(localUser);
    }
    return null;
  }

  Future<void> storeUserLocal(model.User user) async {
    String? preferencesJson;
    if (user.preferences != null) {
      preferencesJson = Preferences.toJsonString(user.preferences!);
    }
    final dbUser = db.User(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      fridgeId: user.fridgeId,
      cookbookId: user.cookbookId,
      fcmToken: user.fcmToken,
      profilePicture: user.profilePicture,
      preferencesJson: preferencesJson,
    );
    await database.userDao.insertUser(dbUser);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
  }

  Future<List<model.User>> fetchFriendsLocal(String userId) async {
    final friends = await database.friendDao.getFriendsForUser(userId);
    return friends.map((f) => model.User.fromDb(f as db.User)).toList();
  }

  // --- Remote API Methods ---

  Future<model.User?> fetchUserRemote() async {
    return await userService.getUserData();
  }

  Future<model.User?> fetchUserProfileRemote(String userId) async {
    return await userService.getUserProfile(userId);
  }

  Future<Map<String, dynamic>?> fetchUserStatsRemote({String? userId}) async {
    return await userService.getUserStats(userId: userId);
  }

  Future<void> updateUserRemote({
    required String firstName,
    required String lastName,
    String? password,
    File? profilePicture,
  }) async {
    await userService.updateUser(
      firstName,
      lastName,
      password ?? '',
      profilePicture,
    );
  }

  Future<void> updateUserPreferencesRemote({
    required List<String> allergies,
    required Map<String, bool> dietaryPreferences,
    required Map<String, bool> notificationPreferences,
  }) async {
    await userService.updateUserPreferences(
      allergies: allergies,
      dietaryPreferences: dietaryPreferences,
      notificationPreferences: notificationPreferences,
    );
  }

  Future<void> updateFcmTokenRemote(String token) async {
    await userService.updateFcmToken(token);
  }

  Future<void> deleteUserRemote() async {
    await userService.deleteUser();
  }
}