import 'app_notification.dart';

class FriendNotification extends AppNotification {
  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime scheduledTime;
  final String friendName;
  final String userId;

  FriendNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.friendName,
    required this.userId,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'friend',
        'id': id,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.toIso8601String(),
        'friendName': friendName,
        'userId': userId, // <-- Include in JSON
      };

  static FriendNotification fromJson(Map<String, dynamic> json) {
    return FriendNotification(
      id: json['id'] ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime'] ?? json['createdAt']),
      friendName: json['friendName'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}