import 'package:flutter/material.dart';
import 'package:snapchef/core/session_manager.dart';

class MockSessionManager implements SessionManager {
  static void createSession(BuildContext context) {
    // Do nothing or optionally call Navigator.pushNamed(context, '/home');
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  static Future<void> clearSession() async {
    // Do nothing
  }
}