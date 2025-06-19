import 'package:snapchef/database/app_database.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/models/user.dart' as model;
import 'package:snapchef/services/user_service.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<model.User?> fetchUserLocal({String? userId}) async => null;

  @override
  Future<void> storeUserLocal(model.User user) async {}

  @override
  Future<List<model.User>> fetchFriendsLocal(String userId) async => [];

  @override
  Future<Map<String, Friend>> getFriendsMap(String currentUserId) async => {};

  @override
  Future<model.User?> fetchUserRemote() async => null;

  @override
  Future<model.User?> fetchUserProfileRemote(String userId) async => null;

  @override
  Future<Map<String, dynamic>?> fetchUserStatsRemote({String? userId}) async => {};

  @override
  Future<void> updateUserRemote({
    required String firstName,
    required String lastName,
    String? password,
    dynamic profilePicture,
  }) async {}

  @override
  Future<void> updateUserPreferencesRemote({
    required List<String> allergies,
    required Map<String, bool> dietaryPreferences,
    required Map<String, bool> notificationPreferences,
  }) async {}

  @override
  Future<void> updateFcmTokenRemote(String token) async {}

  @override
  Future<void> deleteUserRemote() async {}

  @override
  Future<void> storeFriendLocal(model.User friend, String userId) async {}

  @override
  Future<model.User?> fetchFriendLocal(String userId, String friendId) async => null;

  @override
  Future<void> updateFriendFromRemote(String userId, String friendId) async {}

  @override
  Future<void> storeUserStatsLocal(String userId, Map<String, dynamic> stats) async {}

  @override
  Future<Map<String, dynamic>?> fetchUserStatsLocal(String userId) async => {};

  @override  
  AppDatabase get database => throw UnimplementedError();

  @override  
  UserService get userService => throw UnimplementedError();
}