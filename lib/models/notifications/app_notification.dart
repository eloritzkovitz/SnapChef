import 'ingredient_reminder.dart';

abstract class AppNotification {
  String get id;
  String get title;
  String get body;
  DateTime get scheduledTime;

  Map<String, dynamic> toJson();

  static AppNotification fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'expiry':
      case 'grocery':
        return IngredientReminder.fromJson(json);      
      default:
        throw Exception('Unknown notification type: ${json['type']}');
    }
  }
}
