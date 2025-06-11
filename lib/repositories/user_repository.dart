import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
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

  /// Fetches the user from local database.
  /// If [userId] is provided, it fetches that specific user.
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
      // Fetch friends from local DB
      final friends = await fetchFriendsLocal(localUser.id);
      // Pass friends to the User model
      return model.User.fromDb(localUser, friends: friends);
    }
    return null;
  }

  /// Stores the user preferences in the local database.
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
      joinDate: user.joinDate?.toIso8601String(),
    );
    await database.userDao.insertUser(dbUser);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
  }

  /// Fetches the user preferences from the local database.
  Future<List<model.User>> fetchFriendsLocal(String userId) async {
    final friends = await database.friendDao.getFriendsForUser(userId);
    return friends.map((f) => model.User.fromFriendDb(f)).toList();
  }

  /// Returns a map of friendId to User for fast lookup.
  Future<Map<String, db.Friend>> getFriendsMap(String currentUserId) async {
    final friends = await database.friendDao.getFriendsForUser(currentUserId);
    final friendMap = {for (var f in friends) f.friendId: f};
    return friendMap;
  }

  // --- Remote API Methods ---

  /// Fetches the current user from remote API.
  Future<model.User?> fetchUserRemote() async {
    return await userService.getUserData();
  }

  /// Fetches a user's profile from remote API.
  Future<model.User?> fetchUserProfileRemote(String userId) async {
    return await userService.getUserProfile(userId);
  }

  /// Fetches a user's statistics from remote API.
  Future<Map<String, dynamic>?> fetchUserStatsRemote({String? userId}) async {
    return await userService.getUserStats(userId: userId);
  }

  /// Updates the user's data on remote API.
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

  /// Updates the user's preferences on remote API.
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

  /// Adds FCM token to the user on remote API.
  Future<void> updateFcmTokenRemote(String token) async {
    await userService.updateFcmToken(token);
  }

  /// Deletes the user from remote API.
  Future<void> deleteUserRemote() async {
    await userService.deleteUser();
  }

  // --- Friend Management Methods ---

  /// Stores or updates a friend in the local DB.
  Future<void> storeFriendLocal(model.User friend, String userId) async {
    final existing = await database.friendDao.getFriend(userId, friend.id);

    if (existing != null) {
      // Update existing friend
      final dbFriend = db.Friend(
        id: existing.id,
        userId: userId,
        friendId: friend.id,
        friendName: '${friend.firstName} ${friend.lastName}',
        friendEmail: friend.email,
        friendProfilePicture: friend.profilePicture,
        friendJoinDate: friend.joinDate?.toIso8601String(),
      );
      await database.friendDao.insertOrUpdateFriend(dbFriend);
    } else {
      // Insert new friend
      final dbFriend = db.FriendsCompanion.insert(
        userId: userId,
        friendId: friend.id,
        friendName: '${friend.firstName} ${friend.lastName}',
        friendEmail: friend.email,
        friendProfilePicture: Value(friend.profilePicture),
        friendJoinDate: Value(friend.joinDate?.toIso8601String()),
      );
      await database.friendDao.insertFriend(dbFriend);
    }  
  }

  /// Fetches a friend from the local DB.
  Future<model.User?> fetchFriendLocal(String userId, String friendId) async {
    final dbFriend = await database.friendDao.getFriend(userId, friendId);
    if (dbFriend != null) {
      return model.User(
        id: dbFriend.friendId,
        firstName: dbFriend.friendName.split(' ').first,
        lastName: dbFriend.friendName.split(' ').skip(1).join(' '),
        email: dbFriend.friendEmail,
        profilePicture: dbFriend.friendProfilePicture,
        joinDate: dbFriend.friendJoinDate != null
            ? DateTime.tryParse(dbFriend.friendJoinDate!)
            : null,
        fridgeId: '',
        cookbookId: '',
      );
    }
    return null;
  }  

  /// Updates local friend after fetching full profile from remote.
  Future<void> updateFriendFromRemote(String userId, String friendId) async {
    final remoteFriend = await fetchUserProfileRemote(friendId);
    if (remoteFriend != null) {
      await storeFriendLocal(remoteFriend, userId);
    }
  }

  // --- User Stats Methods ---

  /// Stores user stats in the local DB.
  Future<void> storeUserStatsLocal(
      String userId, Map<String, dynamic> stats) async {
    await database.userStatsDao.insertOrUpdateUserStats(
      db.UserStatsCompanion(
        userId: Value(userId),
        ingredientCount: Value(stats['ingredientCount'] ?? 0),
        recipeCount: Value(stats['recipeCount'] ?? 0),
        favoriteRecipeCount: Value(stats['favoriteRecipeCount'] ?? 0),
        friendCount: Value(stats['friendCount'] ?? 0),
        mostPopularIngredients: Value(stats['mostPopularIngredients'] != null
            ? jsonEncode(stats['mostPopularIngredients'])
            : jsonEncode([])),
      ),
    );
  }

  /// Fetches user stats from the local DB.
  Future<Map<String, dynamic>?> fetchUserStatsLocal(String userId) async {
    final dbStats = await database.userStatsDao.getUserStats(userId);
    if (dbStats != null) {
      return {
        'ingredientCount': dbStats.ingredientCount ?? 0,
        'recipeCount': dbStats.recipeCount ?? 0,
        'favoriteRecipeCount': dbStats.favoriteRecipeCount ?? 0,
        'friendCount': dbStats.friendCount ?? 0,
        'mostPopularIngredients': dbStats.mostPopularIngredients != null
            ? jsonDecode(dbStats.mostPopularIngredients!)
            : [],
      };
    }
    return null;
  }
}
