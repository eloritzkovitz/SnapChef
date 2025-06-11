import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/notification_table.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [Notifications])
class NotificationDao extends DatabaseAccessor<AppDatabase> with _$NotificationDaoMixin {
  NotificationDao(super.db);

  // CRUD
  Future<List<Notification>> getAllNotifications() => select(notifications).get();
  Stream<List<Notification>> watchAllNotifications() => select(notifications).watch();
  Future<Notification?> getNotificationById(String id) => (select(notifications)..where((n) => n.id.equals(id))).getSingleOrNull();
  Future<int> insertNotification(Insertable<Notification> notification) => into(notifications).insertOnConflictUpdate(notification);
  Future<bool> updateNotification(Insertable<Notification> notification) => update(notifications).replace(notification);
  Future<int> deleteNotification(String id) => (delete(notifications)..where((n) => n.id.equals(id))).go();

  // Mark as read
  Future<int> markAsRead(String id) =>
      (update(notifications)..where((n) => n.id.equals(id))).write(NotificationsCompanion(isRead: Value(true)));

  // Filter by type
  Future<List<Notification>> filterByType(String type) =>
      (select(notifications)..where((n) => n.type.equals(type))).get();
}