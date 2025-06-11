import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  // CRUD
  Future<List<User>> getAllUsers() => select(users).get();
  Stream<List<User>> watchAllUsers() => select(users).watch();
  Future<User?> getUserById(String id) => (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  Future<int> insertUser(Insertable<User> user) => into(users).insertOnConflictUpdate(user);
  Future<bool> updateUser(Insertable<User> user) => update(users).replace(user);
  Future<int> deleteUser(String id) => (delete(users)..where((u) => u.id.equals(id))).go();

  // Search by email
  Future<User?> getUserByEmail(String email) => (select(users)..where((u) => u.email.equals(email))).getSingleOrNull();

  // Update FCM token
  Future<int> updateFcmToken(String id, String? token) =>
      (update(users)..where((u) => u.id.equals(id))).write(UsersCompanion(fcmToken: Value(token)));
}