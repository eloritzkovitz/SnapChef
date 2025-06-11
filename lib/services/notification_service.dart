import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../models/notifications/app_notification.dart';
import '../models/notifications/ingredient_reminder.dart';
import '../theme/colors.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Get the singleton instance of NotificationService
  Future<List<AppNotification>> getStoredNotifications() async {
    return await _getStoredNotifications();
  }

  // Initialize notification service
  Future<void> initNotification() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  // Define notification details
  NotificationDetails notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'snapchef_channel',
        'SnapChef Notifications',
        channelDescription: 'Notifications for the SnapChef app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        color: primaryColor,
        groupKey: 'SnapChef',
        setAsGroupSummary: false,
      ),
      iOS: const DarwinNotificationDetails(
        threadIdentifier: 'SnapChef',
      ),
    );
  }

  // Show a simple notification (for testing purposes)
  Future<void> showNotification(String title, String body) async {
    await notificationsPlugin.show(0, title, body, notificationDetails());
  }

  // Retrieve stored notifications from local storage
  Future<List<AppNotification>> _getStoredNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('app_notifications');
    if (jsonList == null) return [];
    return jsonList.map((json) {
      final map = jsonDecode(json);
      switch (map['runtimeType']) {
        case 'IngredientReminder':
          return IngredientReminder.fromJson(map);
        // Add more cases for future notification types
        default:
          throw Exception('Unknown notification type: ${map['runtimeType']}');
      }
    }).toList();
  }

  // Save notifications to local storage
  Future<void> _saveStoredNotifications(
      List<AppNotification> notifications) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = notifications.map((n) {
      final map = n.toJson();
      map['runtimeType'] = n.runtimeType.toString();
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList('app_notifications', jsonList);
  }

  // Save notifications to local storage - external access
  Future<void> saveStoredNotifications(
      List<AppNotification> notifications) async {
    await _saveStoredNotifications(notifications);
  }

  // Generate a unique notification ID
  Future<String> generateUniqueNotificationId() async {
    return const Uuid().v4();
  }

  // Schedule a notification (generic)
  Future<void> scheduleNotification(AppNotification notification,
      {String? customTitle}) async {
    try {
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(notification.scheduledTime, tz.local);
      if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Scheduled time is in the past. Skipping.');
        return;
      }

      await notificationsPlugin.zonedSchedule(
        notification.id.hashCode,
        customTitle ?? notification.title,
        notification.body,
        tzScheduledTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Edit an existing notification
  Future<void> editNotification(
      String id, AppNotification updatedNotification) async {
    try {
      List<AppNotification> notifications = await _getStoredNotifications();
      final int index = notifications.indexWhere((n) => n.id == id);

      if (index == -1) {
        debugPrint('Notification with ID $id not found.');
        return;
      }

      await notificationsPlugin.cancel(id.hashCode);

      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(updatedNotification.scheduledTime, tz.local);

      await notificationsPlugin.zonedSchedule(
        updatedNotification.id.hashCode,
        updatedNotification.title,
        updatedNotification.body,
        tzScheduledTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      notifications[index] = updatedNotification;
      await _saveStoredNotifications(notifications);
    } catch (e) {
      debugPrint('Error editing notification: $e');
    }
  }

  // Remove a notification by ID
  Future<void> removeNotification(String id) async {
    try {
      List<AppNotification> notifications = await _getStoredNotifications();
      notifications.removeWhere((n) => n.id == id);

      await notificationsPlugin.cancel(id.hashCode);
      await _saveStoredNotifications(notifications);
    } catch (e) {
      debugPrint('Error removing notification: $e');
    }
  }

  // Retrieve all scheduled notifications (optionally filter by type)
  Future<List<AppNotification>> getScheduledNotifications({Type? type}) async {
    List<AppNotification> notifications = await _getStoredNotifications();
    // Clean up past notifications
    final currentTime = tz.TZDateTime.now(tz.local);
    notifications.removeWhere((n) => n.scheduledTime.isBefore(currentTime));

    // Save the updated list
    await _saveStoredNotifications(notifications);

    if (type != null) {
      notifications =
          notifications.where((n) => n.runtimeType == type).toList();
    }
    return notifications;
  }
}
