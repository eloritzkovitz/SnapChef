import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/expiry_notification.dart';

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

    const InitializationSettings initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'expiry_alerts_channel',
        'Expiry Alerts',
        channelDescription: 'Notifications for ingredient expiry alerts',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
    );
  }

  Future<void> showNotification(String title, String body) async {
    await notificationsPlugin.show(0, title, body, notificationDetails());
  }

  Future<List<ExpiryNotification>> _getStoredNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('scheduled_notifications');
    if (jsonList == null) return [];
    return jsonList.map((json) => ExpiryNotification.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _saveStoredNotifications(List<ExpiryNotification> notifications) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('scheduled_notifications', jsonList);
  }

  Future<int> _generateUniqueNotificationId(List<ExpiryNotification> existingNotifications) async {
    if (existingNotifications.isEmpty) return 1;
    final ids = existingNotifications.map((n) => n.id).toList();
    return ids.reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> scheduleExpiryNotification(String ingredientName, DateTime expiryDateTime) async {
    try {
      final List<ExpiryNotification> notifications = await _getStoredNotifications();

      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(expiryDateTime, tz.local);
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Scheduled time is in the past. Skipping.');
        return;
      }

      final int id = await _generateUniqueNotificationId(notifications);

      await notificationsPlugin.zonedSchedule(
        id,
        "Expiry Alert",
        "$ingredientName is about to expire! Make sure to use it!",
        scheduledTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      final newNotification = ExpiryNotification(
        id: id,
        ingredientName: ingredientName,
        body: "$ingredientName is about to expire! Make sure to use it!",
        scheduledTime: expiryDateTime,
      );

      notifications.add(newNotification);
      await _saveStoredNotifications(notifications);
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> editNotification(int id, ExpiryNotification updatedNotification) async {
    try {
      List<ExpiryNotification> notifications = await _getStoredNotifications();
      final int index = notifications.indexWhere((n) => n.id == id);

      if (index == -1) {
        debugPrint('Notification with ID $id not found.');
        return;
      }

      await notificationsPlugin.cancel(id);

      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(updatedNotification.scheduledTime, tz.local);

      await notificationsPlugin.zonedSchedule(
        updatedNotification.id,
        "Expiry Alert",
        "${updatedNotification.ingredientName} is about to expire! Make sure to use it!",
        scheduledTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      notifications[index] = updatedNotification;
      await _saveStoredNotifications(notifications);
    } catch (e) {
      debugPrint('Error editing notification: $e');
    }
  }

  Future<void> removeNotification(int id) async {
    try {
      List<ExpiryNotification> notifications = await _getStoredNotifications();
      notifications.removeWhere((n) => n.id == id);

      await notificationsPlugin.cancel(id);
      await _saveStoredNotifications(notifications);
    } catch (e) {
      debugPrint('Error removing notification: $e');
    }
  }

  Future<List<ExpiryNotification>> getScheduledNotifications() async {
    List<ExpiryNotification> notifications = await _getStoredNotifications();
    // Clean up expired notifications
    final currentTime = tz.TZDateTime.now(tz.local);
    notifications.removeWhere((notification) => notification.scheduledTime.isBefore(currentTime));

    // Save the updated list
    await _saveStoredNotifications(notifications);
    return notifications;
  }
}