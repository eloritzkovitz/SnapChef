import 'app_notification.dart';

enum ReminderType { expiry, grocery }

class IngredientReminder implements AppNotification {
  @override
  final int id;
  final String ingredientName;
  @override
  final String title;  
  @override
  final String body;
  @override
  final DateTime scheduledTime;
  final ReminderType type;

  IngredientReminder({
    required this.id,
    required this.ingredientName,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.type,
  }); 

  Map<String, dynamic> toJson() => {
    'id': id,
    'ingredientName': ingredientName,
    'title': title,
    'body': body,
    'scheduledTime': scheduledTime.toIso8601String(),
    'type': type.name,
  };

  static IngredientReminder fromJson(Map<String, dynamic> json) => IngredientReminder(
    id: json['id'],
    ingredientName: json['ingredientName'],
    title: json['title'] ?? 'Ingredient Reminder',
    body: json['body'],
    scheduledTime: DateTime.parse(json['scheduledTime']),
    type: ReminderType.values.firstWhere((e) => e.name == json['type']),
  );
}