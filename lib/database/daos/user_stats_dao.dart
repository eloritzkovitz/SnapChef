import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_stats_table.dart';

part 'user_stats_dao.g.dart';

@DriftAccessor(tables: [UserStats])
class UserStatsDao extends DatabaseAccessor<AppDatabase>
    with _$UserStatsDaoMixin {
  UserStatsDao(super.db);

  Future<void> insertOrUpdateUserStats(UserStatsCompanion stats) async {
    await into(userStats).insertOnConflictUpdate(stats);
  }

  Future<UserStat?> getUserStats(String userId) async {
    return (select(userStats)..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> deleteUserStats(String userId) async {
    await (delete(userStats)..where((tbl) => tbl.userId.equals(userId))).go();
  }
}
