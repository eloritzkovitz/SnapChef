import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/services/notification_service.dart';
import 'package:snapchef/services/backend_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final BackendNotificationService _backendService =
      BackendNotificationService(baseUrl: dotenv.env['SERVER_IP']!);

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  NotificationsViewModel() {
    _initialize();
    _startAutoRefresh();
  }

  // Start a periodic timer to refresh notifications
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      syncNotifications();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Initialize the notification service and load the notifications
  Future<void> _initialize() async {
    await _notificationService.initNotification();
    await syncNotifications();
  }

  // Sync backend and local notifications
  Future<void> syncNotifications() async {
    _isLoading = true;
    notifyListeners();

    // Fetch from backend
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
    await syncNotifications();
  }

  // Edit an existing notification
  Future<void> editNotification(
      String id, AppNotification updatedNotification) async {
    final backendNotif =
        await _backendService.updateNotification(id, updatedNotification);
    await _notificationService.editNotification(id, backendNotif);
    await syncNotifications();
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    await _backendService.deleteNotification(id);
    await _notificationService.removeNotification(id);
    await syncNotifications();
  }
}