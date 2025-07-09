import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/services/notification_service.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> editNotification(String id, AppNotification updatedNotification) {
    throw UnimplementedError();
  }

  @override
  Future<String> generateUniqueNotificationId() {
    throw UnimplementedError();
  }

  @override
  Future<List<AppNotification>> getScheduledNotifications({Type? type}) {
    throw UnimplementedError();
  }

  @override
  Future<List<AppNotification>> getStoredNotifications() {
    throw UnimplementedError();
  }

  @override
  Future<void> initNotification() {
    throw UnimplementedError();
  }

  @override
  NotificationDetails notificationDetails() {
    throw UnimplementedError();
  }

  @override
  FlutterLocalNotificationsPlugin get notificationsPlugin => throw UnimplementedError();

  @override
  Future<void> removeNotification(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveStoredNotifications(List<AppNotification> notifications) {
    throw UnimplementedError();
  }

  @override
  Future<void> scheduleNotification(AppNotification notification, {String? customTitle}) {
    throw UnimplementedError();
  }

  @override
  Future<void> showNotification(String title, String body) {
    throw UnimplementedError();
  }
}