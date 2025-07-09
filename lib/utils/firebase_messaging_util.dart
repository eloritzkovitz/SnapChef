import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

// Top-level variables for testability
Future<void> Function(RemoteMessage) firebaseMessagingBackgroundHandler =
    FirebaseMessagingUtil.firebaseMessagingBackgroundHandler;
Future<void> Function() requestNotificationPermissions =
    FirebaseMessagingUtil.requestNotificationPermissions;
Future<String?> Function() getDeviceToken =
    FirebaseMessagingUtil.getDeviceToken;
void Function() listenForForegroundMessages =
    FirebaseMessagingUtil.listenForForegroundMessages;

class FirebaseMessagingUtil {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Background message handler for Firebase Messaging.
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log('Handling a background message: ${message.messageId}');
  }

  /// Requests notification permissions from the user.
  static Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional notification permission');
    } else {
      log('User declined or has not accepted notification permission');
    }
  }

  /// Gets the FCM token.
  static Future<String?> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      log('FCM Token: $token');
      return token;
    } catch (e) {
      log('Error fetching FCM token: $e');
      return null;
    }
  }

  /// Listens for foreground messages.
  static void listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Received a message while in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }
}
