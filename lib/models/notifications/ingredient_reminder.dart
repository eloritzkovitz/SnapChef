import 'app_notification.dart';

enum ReminderType { expiry, grocery, notice }

class IngredientReminder implements AppNotification {
  @override
  final String id;
  final String ingredientName;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime scheduledTime;
  final ReminderType typeEnum;
  final String recipientId;

  IngredientReminder({
    required this.id,
    required this.ingredientName,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.typeEnum,
    required this.recipientId,
  });

  @override
  String get type => typeEnum.name;

  IngredientReminder copyWith({
    String? id,
    String? ingredientName,
    String? title,
    String? body,
    DateTime? scheduledTime,
    ReminderType? typeEnum,
    String? recipientId,
  }) {
    return IngredientReminder(
      id: id ?? this.id,
      ingredientName: ingredientName ?? this.ingredientName,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      typeEnum: typeEnum ?? this.typeEnum,
      recipientId: recipientId ?? this.recipientId,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'ingredientName': ingredientName,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.toIso8601String(),
        'type': typeEnum.name,
        'recipientId': recipientId,
      };

  static IngredientReminder fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'];
    if (rawId == null) throw Exception('Notification is missing an id/_id');
    final id = rawId.toString();

    final rawType = json['type'];
    if (rawType != 'expiry' && rawType != 'grocery' && rawType != 'notice') {
      throw Exception(
          'Unsupported notification type for IngredientReminder: $rawType');
    }

    final rawScheduledTime = json['scheduledTime'];
    if (rawScheduledTime == null) {
      throw Exception('Notification is missing scheduledTime');
    }

    return IngredientReminder(
      id: id,
      ingredientName: json['ingredientName'] ?? '',
      title: json['title'] ?? 'Ingredient Reminder',
      body: json['body'] ?? '',
      scheduledTime: DateTime.parse(rawScheduledTime),
      typeEnum: ReminderType.values.firstWhere((e) => e.name == rawType),
      recipientId: json['recipientId'] ?? '',
    );
  }
}
