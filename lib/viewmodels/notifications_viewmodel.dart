import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/services/notification_service.dart';
import 'package:snapchef/services/backend_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapchef/utils/token_util.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final BackendNotificationService _backendService =
      BackendNotificationService(baseUrl: dotenv.env['SERVER_IP']!);

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  StreamSubscription<AppNotification>? _wsSubscription;
  Timer? _refreshTimer;

  // Alerts: only future expiry/grocery notifications
  List<AppNotification> get alerts => _notifications
      .where((n) =>
          (n.type == 'expiry' || n.type == 'grocery') &&
          n.scheduledTime.isAfter(DateTime.now()))
      .toList();

  // Notifications: all others, plus expired alerts
  List<AppNotification> get notifications => _notifications
      .where((n) =>
          n.type != 'expiry' && n.type != 'grocery' ||
          ((n.type == 'expiry' || n.type == 'grocery') &&
              n.scheduledTime.isBefore(DateTime.now())))
      .toList();

  bool get isLoading => _isLoading;

  NotificationsViewModel() {
    _initialize();
    _startAutoRefresh();
    _startAutoCleanup();
  }

  // Start a periodic timer to refresh notifications every 5 minutes
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      syncNotifications();
    });
  }

  // Periodically move expired alerts to notifications and remove from alerts
  void _startAutoCleanup() {
    Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      final expiredAlerts = _notifications
          .where((n) =>
              (n.type == 'expiry' || n.type == 'grocery') &&
              n.scheduledTime.isBefore(now))
          .toList();

      for (final alert in expiredAlerts) {
        await deleteNotification(alert.id);
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _wsSubscription?.cancel();
    _backendService.disconnectWebSocket();
    super.dispose();
  }

  // Initialize the notification service and load the notifications
  Future<void> _initialize() async {
    await _notificationService.initNotification();
    await syncNotifications();
  }

  // Connect to WebSocket and listen for real-time notifications using context
  Future<void> connectWebSocketAndListenWithContext(
      BuildContext context) async {
    final userToken = await TokenUtil.getAccessToken();
    if (userToken == null) return;

    if (context.mounted) {
      // Get userId from the UserViewModel using Provider and the given context
      final userId =
          Provider.of<UserViewModel>(context, listen: false).user?.id;
      if (userId == null) return;

      _backendService.connectToWebSocket(userToken, userId);

      _wsSubscription =
          _backendService.notificationStream?.listen((notif) async {
        await _notificationService.showNotification(notif.title, notif.body);
        // Prevent duplicates
        if (!_notifications.any((n) => n.id == notif.id)) {
          _notifications.insert(0, notif);
          notifyListeners();
        }
      });
    }
  }

  // Sync backend and local notifications (for initial load or manual refresh)
  Future<void> syncNotifications() async {
    _isLoading = true;
    notifyListeners();

    final backendNotifications = await _backendService.fetchNotifications();

    // Cancel all scheduled notifications in the plugin to avoid duplicates
    await _notificationService.notificationsPlugin.cancelAll();

    // Schedule only backend notifications locally
    for (final notif in backendNotifications) {
      await _notificationService.scheduleNotification(notif);
    }

    // Overwrite local storage with backend notifications
    await _notificationService.saveStoredNotifications(backendNotifications);

    _notifications = backendNotifications;
    _isLoading = false;
    notifyListeners();
  }

  // Generate a unique notification ID
  Future<String> generateUniqueNotificationId() async {
    return await _notificationService.generateUniqueNotificationId();
  }

  // Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    await _backendService.createNotification(notification);
  }

  // Edit an existing notification
  Future<void> editNotification(
      String id, AppNotification updatedNotification) async {
    final backendNotif =
        await _backendService.updateNotification(id, updatedNotification);
    await _notificationService.editNotification(id, backendNotif);
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    await _backendService.deleteNotification(id);
    await _notificationService.removeNotification(id);
  }
}