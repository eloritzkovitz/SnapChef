import 'dart:convert';
import '../constants/notification_preferences.dart';

class Preferences {
  final List<String> allergies;
  final Map<String, bool> dietaryPreferences;
  final Map<String, bool> notificationPreferences;

  Preferences({
    required this.allergies,
    required this.dietaryPreferences,
    Map<String, bool>? notificationPreferences,
  }) : notificationPreferences = notificationPreferences ??
            {
              for (final key in allNotificationPreferenceKeys) key: true,
            };

  factory Preferences.fromJson(Map<String, dynamic> json) {
    final notifPrefs =
        Map<String, bool>.from(json['notificationPreferences'] ?? {});
    // Ensure all keys are present with defaults
    for (final key in allNotificationPreferenceKeys) {
      notifPrefs.putIfAbsent(key, () => true);
    }
    return Preferences(
      allergies: List<String>.from(json['allergies'] ?? []),
      dietaryPreferences:
          Map<String, bool>.from(json['dietaryPreferences'] ?? {}),
      notificationPreferences: notifPrefs,
    );
  }

  Map<String, dynamic> toJson() => {
        'allergies': allergies,
        'dietaryPreferences': dietaryPreferences,
        'notificationPreferences': notificationPreferences,
      };

  Map<String, dynamic> toRecipeJson() => {
        'allergies': allergies,
        'dietaryPreferences': dietaryPreferences,
      };
  
  /// Serialize Preferences to a JSON string for storage
  static String toJsonString(Preferences prefs) {
    return jsonEncode(prefs.toJson());
  }

  /// Deserialize Preferences from a JSON string
  static Preferences fromJsonString(String jsonString) {
    return Preferences.fromJson(jsonDecode(jsonString));
  }
}
