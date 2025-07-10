import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/models/notifications/app_notification.dart';

class MockNotificationsViewModel extends ChangeNotifier
    implements NotificationsViewModel {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _isLoggingOut = false;
  String? _errorMessage;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isLoggingOut => _isLoggingOut;

  @override
  String? get errorMessage => _errorMessage;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void setLoggingOut(bool value) {
    _isLoggingOut = value;
    notifyListeners();
  }

  @override
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void clear() {
    _notifications.clear();
    _isLoading = false;
    _isLoggingOut = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  Future<void> syncNotifications() async {}

  Future<void> Function(AppNotification, [String?])? addNotificationCallback;
  Future<String> Function()? generateUniqueNotificationIdCallback;
  Future<void> Function(String, AppNotification)? editNotificationCallback;
  Future<void> Function(String)? deleteNotificationCallback;

  @override
  Future<void> addNotification(AppNotification notification,
      [String? userId]) async {
    if (addNotificationCallback != null) {
      return addNotificationCallback!(notification, userId);
    }
    _notifications.add(notification);
    notifyListeners();
  }

  @override
  Future<void> editNotification(
      String id, AppNotification updatedNotification) async {    
    if (editNotificationCallback != null) {
      return editNotificationCallback!(id, updatedNotification);
    }
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = updatedNotification;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    if (deleteNotificationCallback != null) {
      return deleteNotificationCallback!(id);
    }
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  @override
  Future<String> generateUniqueNotificationId() async {
    if (generateUniqueNotificationIdCallback != null) {
      return await generateUniqueNotificationIdCallback!();
    }
    return 'mock-id';
  }

  @override
  Future<void> connectWebSocketAndListenWithContext(context) async {}

  @override
  ConnectivityProvider get connectivityProvider => throw UnimplementedError();

  @override
  SyncManager get syncManager => throw UnimplementedError();

  @override
  SyncProvider get syncProvider => throw UnimplementedError();

  bool disableTimeFilter = false;

  @override
  List<AppNotification> get alerts {
    if (disableTimeFilter) return _notifications;
    final filtered = _notifications.where((n) {
      if (n is IngredientReminder) {
        return (n.typeEnum == ReminderType.expiry ||
                n.typeEnum == ReminderType.grocery) &&
            n.scheduledTime.isAfter(DateTime.now());
      }
      return false;
    }).toList();
    return filtered;
  }

  @override
  List<AppNotification> get notifications => _notifications
      .where((n) =>
          n.type != 'expiry' && n.type != 'grocery' ||
          ((n.type == 'expiry' || n.type == 'grocery') &&
              n.scheduledTime.isBefore(DateTime.now())))
      .toList();

  set alerts(List<AppNotification> value) {
    _notifications = value;
    notifyListeners();
  }

  set notifications(List<AppNotification> value) {
    _notifications = value;
    notifyListeners();
  }

  @override  
  Timer? get cleanupTimerInternal => throw UnimplementedError();

  @override  
  List<AppNotification> get notificationsInternal => throw UnimplementedError();
  
  @override  
  Timer? get refreshTimerInternal => throw UnimplementedError();

  @override  
  StreamSubscription<AppNotification>? get wsSubscriptionInternal => throw UnimplementedError();
  
  @override
  set cleanupTimerInternal(Timer? t) {   
  }
  
  @override
  set refreshTimerInternal(Timer? t) {  
  }
  
  @override
  set wsSubscriptionInternal(StreamSubscription<AppNotification>? s) {  
  }
}
