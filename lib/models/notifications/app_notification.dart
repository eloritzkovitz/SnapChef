import 'ingredient_reminder.dart';
import 'friend_notification.dart';
import 'share_notification.dart';

abstract class AppNotification {
  String get id;
  String get title;
  String get body;
  String get type;
  DateTime get scheduledTime;

  Map<String, dynamic> toJson();

  static AppNotification fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'expiry':
      case 'grocery':
      case 'notice':
        return IngredientReminder.fromJson(json);
      case 'friend':
        return FriendNotification.fromJson(json);
      case 'share':
        return ShareNotification.fromJson(json);
      default:
        throw Exception('Unknown notification type: ${json['type']}');
    }
  }
}
