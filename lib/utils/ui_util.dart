import 'package:flutter/material.dart';

class UIUtil {

  // --- SnackBar Utility Methods ---

  /// Show error message in a SnackBar.
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Show unavailable offline message in a SnackBar.
  static void showUnavailableOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unavailable offline.')),
    );
  }

  /// Show unavailable offline message in a SnackBar.
  static void showOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are offline.')),
    );
  }

  /// Show "Back online" message in a SnackBar.
  static void showBackOnline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Back online!')),
    );
  }

  // --- String Formatting and Utility Methods ---

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
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
