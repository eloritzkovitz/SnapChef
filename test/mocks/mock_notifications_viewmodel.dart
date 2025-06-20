import 'package:flutter/foundation.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/models/notifications/app_notification.dart';

class MockNotificationsViewModel extends ChangeNotifier implements NotificationsViewModel {
  final List<AppNotification> _notifications = [];
  final bool _isLoading = false;

  @override
  List<AppNotification> get alerts => _notifications;

  @override
  List<AppNotification> get notifications => _notifications;

  @override
  bool get isLoading => _isLoading;
  
  @override
  Future<void> syncNotifications() async {}

  @override
  Future<void> addNotification(AppNotification notification, [String? userId]) async {
    _notifications.add(notification);
    notifyListeners();
  }

  @override
  Future<void> editNotification(String id, AppNotification updatedNotification) async {}

  @override
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  @override
  Future<String> generateUniqueNotificationId() async => 'mock-id';

  // If your UI uses connectWebSocketAndListenWithContext, you can add a dummy:
  @override
  Future<void> connectWebSocketAndListenWithContext(context) async {}

  @override  
  ConnectivityProvider get connectivityProvider => throw UnimplementedError();

  @override  
  SyncManager get syncManager => throw UnimplementedError();

  @override  
  SyncProvider get syncProvider => throw UnimplementedError(); 
}