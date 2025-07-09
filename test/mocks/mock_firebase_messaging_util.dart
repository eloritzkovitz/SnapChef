import 'package:snapchef/utils/firebase_messaging_util.dart';

class MockFirebaseMessagingUtil extends FirebaseMessagingUtil {
  static bool requestedPermissions = false;
  static bool listenedForForegroundMessages = false;

  static Future<void> requestNotificationPermissions() async {
    requestedPermissions = true;
  }

  static Future<String?> getDeviceToken() async {
    return 'fake_token';
  }

  static void listenForForegroundMessages() {
    listenedForForegroundMessages = true;
  }

  static Future<void> firebaseMessagingBackgroundHandler(message) async {
    // Do nothing or log for test
  }
}