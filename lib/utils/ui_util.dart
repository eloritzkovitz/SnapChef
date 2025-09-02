import 'package:flutter/material.dart';

void Function(BuildContext, String) showError = UIUtil.showError;
void Function(BuildContext) showBackOnline = UIUtil.showBackOnline;
void Function(BuildContext) showOffline = UIUtil.showOffline;

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

  /// Show sync in progress message in a SnackBar.
  static void showSyncInProgress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync is in progress. Please wait...')),
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

  /// Returns a short relative time string for a scheduled date.  
  static String formatNotificationRelative(DateTime scheduled) {
  final now = DateTime.now();
  final diff = scheduled.difference(now);

  // Use absolute value for formatting
  final absDiff = diff.isNegative ? -diff : diff;

  String unit;
  int value;

  if (absDiff.inSeconds < 60) {
    value = absDiff.inSeconds;
    unit = 's';
  } else if (absDiff.inMinutes < 60) {
    value = absDiff.inMinutes;
    unit = 'm';
  } else if (absDiff.inHours < 24) {
    value = absDiff.inHours;
    unit = 'h';
  } else if (absDiff.inDays < 7) {
    value = absDiff.inDays;
    unit = 'd';
  } else if (absDiff.inDays < 30) {
    value = (absDiff.inDays / 7).floor();
    unit = 'w';
  } else if (absDiff.inDays < 365) {
    value = (absDiff.inDays / 30).floor();
    unit = 'mo';
  } else {
    value = (absDiff.inDays / 365).floor();
    unit = 'y';
  }
  
  return diff.isNegative ? '$value$unit' : '$value$unit';
}
}
