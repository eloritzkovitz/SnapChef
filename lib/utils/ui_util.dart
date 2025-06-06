import 'package:flutter/material.dart';

class UIUtil {
  /// Show error message in a SnackBar.
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Show unavailable offline message in a SnackBar.
  void showOfflineSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unavailable offline')),
    );
  }

  /// Formats a string to capitalize the first letter in each word.
  String capitalize(String s) {
    return s
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  /// Get a greeting based on the current time of day.
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Formats a raw date string to a more readable format.
  static String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final date = DateTime.parse(rawDate);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return rawDate;
    }
  }
}
