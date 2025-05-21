import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notifications/app_notification.dart';
import '../models/notifications/ingredient_reminder.dart';
import '../theme/colors.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

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
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'ingredient_alerts_channel',
        'Ingredient Alerts',
        channelDescription: 'Notifications for ingredient reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        color: primaryColor,
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
  Future<void> _saveStoredNotifications(List<AppNotification> notifications) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = notifications.map((n) {
      final map = n.toJson();
      map['runtimeType'] = n.runtimeType.toString();
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList('app_notifications', jsonList);
  }

  // Generate a unique notification ID
  int _generateUniqueNotificationIdFromList(List<AppNotification> existingNotifications) {
    if (existingNotifications.isEmpty) return 1;
    final ids = existingNotifications.map((n) => n.id).toList();
    return ids.reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<int> generateUniqueNotificationId() async {
    final existingNotifications = await _getStoredNotifications();
    return _generateUniqueNotificationIdFromList(existingNotifications);
  }

  // Schedule a notification (generic)
  Future<void> scheduleNotification(AppNotification notification, {String? customTitle}) async {
    try {
      final List<AppNotification> notifications = await _getStoredNotifications();

      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(notification.scheduledTime, tz.local);
      if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Scheduled time is in the past. Skipping.');
        return;
      }

      await notificationsPlugin.zonedSchedule(
        notification.id,
        customTitle ?? notification.title,
        notification.body,
        tzScheduledTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      notifications.add(notification);
      await _saveStoredNotifications(notifications);
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Edit an existing notification
  Future<void> editNotification(int id, AppNotification updatedNotification) async {
    try {
      List<AppNotification> notifications = await _getStoredNotifications();
      final int index = notifications.indexWhere((n) => n.id == id);

      if (index == -1) {
        debugPrint('Notification with ID $id not found.');
        return;
      }

      await notificationsPlugin.cancel(id);

      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(updatedNotification.scheduledTime, tz.local);

      await notificationsPlugin.zonedSchedule(
        updatedNotification.id,
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
  Future<void> removeNotification(int id) async {
    try {
      List<AppNotification> notifications = await _getStoredNotifications();
      notifications.removeWhere((n) => n.id == id);

      await notificationsPlugin.cancel(id);
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
      notifications = notifications.where((n) => n.runtimeType == type).toList();
    }
    return notifications;
  }
}