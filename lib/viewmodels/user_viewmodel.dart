import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/base_viewmodel.dart';
import '../models/user.dart' as model;
import '../models/preferences.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/user_service.dart';
import '../utils/ui_util.dart';
import '../database/app_database.dart' as db;
import '../providers/connectivity_provider.dart';
import '../repositories/user_repository.dart';

class UserViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final db.AppDatabase database = GetIt.I<db.AppDatabase>();
  final ConnectivityProvider connectivityProvider =
      GetIt.I<ConnectivityProvider>();
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final FriendService friendService;

   UserViewModel({FriendService? friendService})
      : friendService = friendService ?? GetIt.I<FriendService>();

  @visibleForTesting
  set userForTest(model.User value) => _user = value;
  
  model.User? _user;
  Map<String, dynamic>? _userStats;
  
  model.User? get user => _user;

  String? get fridgeId => _user?.fridgeId;
  String? get cookbookId => _user?.cookbookId;
  Map<String, dynamic>? get userStats => _userStats;
  List<model.User> get friends => _user?.friends ?? [];

  /// Fetches the current user's data.
  /// This method handles both local and remote data fetching.
  Future<void> fetchUserData() async {
    setLoading(true);
    notifyListeners();

    // 1. Always load local data first for instant display
    await _loadUserFromLocalDb();

    // 2. If offline, stop here (local data is already shown)
    if (connectivityProvider.isOffline) {
      setLoading(false);
      notifyListeners();
      return;
    }

    // 3. If online, fetch from remote and update local data
    try {
      final userProfile = await userRepository.fetchUserRemote().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Network timeout'),
          );
      _user = userProfile;
      notifyListeners();

      // Store user in local DB and SharedPreferences
      if (userProfile != null) {
        await userRepository.storeUserLocal(userProfile);
      }

      // Store friends in local DB
      if (userProfile != null && userProfile.friends.isNotEmpty) {
        for (final friend in userProfile.friends) {
          // Fetch full profile from remote and store locally
          final fullProfile =
              await userRepository.fetchUserProfileRemote(friend.id);
          if (fullProfile != null) {
            await userRepository.storeFriendLocal(fullProfile, userProfile.id);
          }
        }
      }

      // Update FCM token after fetching user data
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await updateFcmToken(fcmToken);

      // Fetch user statistics after fetching user data
      if (_user != null) {
        await fetchUserStats(userId: _user!.id);
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        try {
          await _authService.refreshTokens().timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw Exception('Token refresh timeout'),
              );
          final userProfile = await userRepository.fetchUserRemote().timeout(
                const Duration(seconds: 10),
                onTimeout: () =>
                    throw Exception('Network timeout after refresh'),
              );
          _user = userProfile;
          notifyListeners();

          // Store user in local DB and SharedPreferences
          if (userProfile != null) {
            await userRepository.storeUserLocal(userProfile);
          }

          // Update FCM token after refreshing user data
          final fcmToken = await FirebaseMessaging.instance.getToken();
          await updateFcmToken(fcmToken);

          if (_user != null) {
            await fetchUserStats(userId: _user!.id);
          }
        } catch (refreshError) {
          log('Failed to refresh tokens: $refreshError');
        }
      } else {
        log('Failed to fetch user data: $e');
      }
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Loads the user from local database.
  Future<void> _loadUserFromLocalDb() async {
    try {
      final localUser = await userRepository.fetchUserLocal();
      if (localUser != null) {
        _user = localUser;
        notifyListeners();
      } else {
        _user = null;
        notifyListeners();
      }
    } catch (dbError) {
      _user = null;
      notifyListeners();
    }
  }

  /// Gets the current user's profile.
  Future<List<model.User>> getFriends() async {
    await fetchUserData();
    return _user?.friends ?? [];
  }

  /// Updates the current user's profile.
  Future<void> updateUser({
    required String firstName,
    required String lastName,
    String? password,
    File? profilePicture,
  }) async {
    setLoading(true);
    try {
      await userRepository.updateUserRemote(
        firstName: firstName,
        lastName: lastName,
        password: password,
        profilePicture: profilePicture,
      );
      // Fetch updated user from remote and store locally
      await fetchUserData();
    } catch (e) {
      throw Exception('Failed to update profile');
    } finally {
      setLoading(false);
    }
  }

  // Updates user preferences.
  // Preferences include allergies, dietary preferences and notification settings.
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

    await userRepository.updateUserPreferencesRemote(
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
    await userRepository.storeUserLocal(_user!);
  }

  /// Updates FCM Token for the current user.
  Future<void> updateFcmToken(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      await userRepository.updateFcmTokenRemote(token);
      if (_user != null) {
        _user = _user!.copyWith(fcmToken: token);
        notifyListeners();

        // Store updated user locally
        await userRepository.storeUserLocal(_user!);
      }
    } catch (e) {
      throw Exception('Failed to update FCM token: ${e.toString()}');
    }
  }

  /// Listens for FCM token refresh and updates backend.
  void listenForFcmTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await updateFcmToken(newToken);
    });
  }

  /// Delete the current user account.
  /// This will remove the user from the remote server and local database.
  Future<void> deleteUser(BuildContext context) async {
    setLoading(true);
    try {
      await userRepository.deleteUserRemote();
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
      setLoading(false);
    }
  }  

  // Fetch another user's profile by userId
  Future<model.User?> fetchUserProfile(String userId) async {
    // If offline, fetch from local DB
    if (connectivityProvider.isOffline) {
      return await userRepository.fetchFriendLocal(_user?.id ?? '', userId);
    }

    // If online, fetch from remote and update local DB
    try {
      final userProfile = await userRepository.fetchUserProfileRemote(userId);
      if (userProfile != null && _user != null) {
        await userRepository.storeFriendLocal(userProfile, _user!.id);
      }
      return userProfile;
    } catch (e) {
      // If remote fetch fails, fallback to local
      return await userRepository.fetchFriendLocal(_user?.id ?? '', userId);
    }
  }

  String? sharedUserName;
  String? sharedUserProfilePic;

  /// Fetches the relevant user info for a shared recipe (remote first, then local).
  Future<void> fetchUserInfo({
    required String userId,
    required String currentUserId,
  }) async {
    final userService = GetIt.I<UserService>();
    try {
      // Try remote fetch first
      final user = await userService.getUserProfile(userId);
      sharedUserName = '${user.firstName} ${user.lastName}'.trim();
      sharedUserProfilePic = user.profilePicture;
    } catch (e) {
      // If remote fails, try local lookup
      try {
        final friendMap = await userRepository.getFriendsMap(currentUserId);
        final friend = friendMap[userId];
        if (friend != null) {
          sharedUserName = friend.friendName;
          sharedUserProfilePic = friend.friendProfilePicture;
        } else {
          sharedUserName = null;
          sharedUserProfilePic = null;
        }
      } catch (_) {
        sharedUserName = null;
        sharedUserProfilePic = null;
      }
    }
    notifyListeners();
  }

  /// Fetches user statistics for the current user or a specific userId.
  /// If offline, fetches from local UserStats table.
  Future<void> fetchUserStats({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final id = userId ?? prefs.getString('userId');
    if (id == null) {
      _userStats = null;
      notifyListeners();
      return;
    }

    // 1. If offline, fetch from local UserStats table and stop
    if (connectivityProvider.isOffline) {
      final localStats = await userRepository.fetchUserStatsLocal(id);
      _userStats = localStats;
      notifyListeners();
      return;
    }

    // 2. If online, fetch from backend and cache locally
    try {
      final stats = await userRepository.fetchUserStatsRemote(userId: id);
      if (stats != null) {
        _userStats = stats;
        notifyListeners();
        // Cache stats locally for offline use
        await userRepository.storeUserStatsLocal(id, stats);
      } else {
        // If backend returns null, fallback to local
        final localStats = await userRepository.fetchUserStatsLocal(id);
        _userStats = localStats;
        notifyListeners();
      }
    } catch (e) {
      // On error, fallback to local
      final localStats = await userRepository.fetchUserStatsLocal(id);
      _userStats = localStats;
      notifyListeners();
    }
  }

  /// Removes a friend by their userId.
  Future<void> removeFriend(String friendId) async {
    await friendService.removeFriend(friendId);
    await database.userStatsDao.deleteUserStats(friendId);
    await fetchUserData();
  }

  @override
  void clear() {
    _user = null;
    _userStats = null;    
    sharedUserName = null;
    sharedUserProfilePic = null;   
    setLoggingOut(false); 
    notifyListeners();
  }
}
