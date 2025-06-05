import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/friend_table.dart';

part 'friend_dao.g.dart';

@DriftAccessor(tables: [Friends])
class FriendDao extends DatabaseAccessor<AppDatabase> with _$FriendDaoMixin {
  FriendDao(super.db);

  // CRUD
  Future<List<Friend>> getAllFriends() => select(friends).get();
  Stream<List<Friend>> watchAllFriends() => select(friends).watch();
  Future<Friend?> getFriendById(int id) => (select(friends)..where((f) => f.id.equals(id))).getSingleOrNull();
  Future<int> insertFriend(Insertable<Friend> friend) => into(friends).insertOnConflictUpdate(friend);
  Future<bool> updateFriend(Insertable<Friend> friend) => update(friends).replace(friend);
  Future<int> deleteFriend(int id) => (delete(friends)..where((f) => f.id.equals(id))).go();

  // Filter by user
  Future<List<Friend>> getFriendsForUser(String userId) =>
      (select(friends)..where((f) => f.userId.equals(userId))).get();

  // Filter by status
  Future<List<Friend>> getFriendsByStatus(String userId, String status) =>
      (select(friends)..where((f) => f.userId.equals(userId) & f.status.equals(status))).get();
}