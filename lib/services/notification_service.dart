import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize notification service
  Future<void> initNotification() async {
    if (_isInitialized) return; // Prevent re-initialization

    // Initialize timezone data
    tz.initializeTimeZones();
    final String crrentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(crrentTimeZone));

    // prepare the initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings
    const initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin.initialize(initSettings);
  }

  // Notification details
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

  // Show notification
  Future<void> showNotification(String title, String body) async {
    await notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails(),
    );
  }

  Future<void> scheduleExpiryNotification(
      String ingredientName, DateTime expiryDateTime) async {
    try {
      // Convert expiryDateTime to the local time zone
      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(expiryDateTime, tz.local);

      debugPrint('Scheduling notification for $ingredientName');
      debugPrint('ExpiryDateTime (original): $expiryDateTime');
      debugPrint('ScheduledTime (local): $scheduledTime');

      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint(
            'Error: Scheduled time is in the past. Notification not scheduled.');
        return;
      }

      await notificationsPlugin.zonedSchedule(
        ingredientName.hashCode,
        "Expiry Alert",
        "$ingredientName is about to expire!",
        scheduledTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      debugPrint(
          'Expiry notification successfully scheduled for $ingredientName at $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling expiry notification: $e');
    }
  }

  void scheduleTestNotification() async {
    final DateTime now = DateTime.now();
    final DateTime testDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 3, // Schedule for 1 minute in the future
    );

    await showNotification(
      'Immediate Test', // Notification title
      'This is a test notification sent immediately.', // Notification body
    );

    await NotificationService().scheduleExpiryNotification(
      'Test Message', // Ingredient name or notification title
      testDateTime,
    );
  }
}
