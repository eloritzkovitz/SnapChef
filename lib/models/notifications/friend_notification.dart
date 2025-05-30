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
  final String senderId;
  final String recipientId;

  @override
  String get type => 'friend';

  FriendNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.friendName,
    required this.senderId,
    required this.recipientId,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'friend',
        'id': id,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.toIso8601String(),
        'friendName': friendName,
        'senderId': senderId,
        'recipientId': recipientId,
      };

  static FriendNotification fromJson(Map<String, dynamic> json) {
    return FriendNotification(
      id: json['id'] ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime'] ?? json['createdAt']),
      friendName: json['friendName'] ?? '',
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
    );
  }
}