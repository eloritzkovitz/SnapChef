import 'package:flutter/material.dart';
import 'package:snapchef/models/expiry_notification.dart';
import 'package:snapchef/services/notification_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<ExpiryNotification> _notifications = [];
  bool _isLoading = true;

  List<ExpiryNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  NotificationsViewModel() {
    _initialize();
  }

  // Initialize the notification service and load the notifications
  Future<void> _initialize() async {
    await _notificationService.initNotification();  // Initialize the service
    await _loadNotifications();  // Load notifications
  }

  // Load notifications from the service and update the ViewModel
  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    _notifications = await _notificationService.getScheduledNotifications();  // Get stored notifications

    _isLoading = false;
    notifyListeners();
  }

  // Add a new notification
  Future<void> addNotification(String ingredientName, DateTime expiryDateTime) async {
    await _notificationService.scheduleExpiryNotification(ingredientName, expiryDateTime);
    await _loadNotifications();  // Reload notifications after adding
  }

  // Edit an existing notification
  Future<void> editNotification(int id, ExpiryNotification updatedNotification) async {
    await _notificationService.editNotification(id, updatedNotification);
    await _loadNotifications();  // Reload notifications after editing
  }

  // Delete a notification
  Future<void> deleteNotification(int id) async {
    await _notificationService.removeNotification(id);
    await _loadNotifications();  // Reload notifications after deleting
  }
}
