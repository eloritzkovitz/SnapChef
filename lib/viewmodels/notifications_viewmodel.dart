import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/services/notification_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
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
      _loadNotifications();
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
    await _loadNotifications();
  }

  // Load notifications from the service and update the ViewModel
  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    _notifications = await _notificationService.getScheduledNotifications();

    _isLoading = false;
    notifyListeners();
  }

  // Generate a unique notification ID
  Future<int> generateUniqueNotificationId() async {
    return await _notificationService.generateUniqueNotificationId();
  }

  // Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    await _notificationService.initNotification();
    await _notificationService.scheduleNotification(notification);
    await _loadNotifications();
  }

  // Edit an existing notification
  Future<void> editNotification(
      int id, AppNotification updatedNotification) async {
    await _notificationService.editNotification(id, updatedNotification);
    await _loadNotifications();
  }

  // Delete a notification
  Future<void> deleteNotification(int id) async {
    await _notificationService.removeNotification(id);
    await _loadNotifications();
  }
}