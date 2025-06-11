import '../../models/notifications/app_notification.dart';
import '../../services/backend_notification_service.dart';

/// Handles notification-related sync actions.
class NotificationSyncActions {
  final BackendNotificationService backendService;

  NotificationSyncActions(this.backendService);

  /// Processes a notification action based on the action type.
  Future<void> handleNotificationAction(Map<String, dynamic> action) async {
    switch (action['action']) {
      case 'add':
        await _addNotification(action);
        break;
      case 'edit':
        await _editNotification(action);
        break;
      case 'delete':
        await _deleteNotification(action);
        break;
      default:
        break;
    }
  }

  /// Adds a notification based on the action details.
  Future<void> _addNotification(Map<String, dynamic> action) async {
    final notification = AppNotification.fromJson(action['notification'] as Map<String, dynamic>);
    await backendService.createNotification(notification);
  }

  /// Edits a notification based on the action details.
  Future<void> _editNotification(Map<String, dynamic> action) async {
    final notification = AppNotification.fromJson(action['notification'] as Map<String, dynamic>);
    await backendService.updateNotification(notification.id, notification);
  }

  /// Deletes a notification based on the action details.
  Future<void> _deleteNotification(Map<String, dynamic> action) async {
    await backendService.deleteNotification(action['notificationId']);
  }
}