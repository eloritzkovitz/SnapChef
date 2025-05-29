import 'app_notification.dart';

class ShareNotification extends AppNotification {
  @override
  final String id;
  @override
  final String title;
  @override
  final String body;  
  @override
  final DateTime scheduledTime;
  final String? friendName;
  final String? recipeName;
  final String senderId;
  final String recipientId;

  @override
  String get type => 'share';

  ShareNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.friendName,
    this.recipeName,
    required this.senderId,
    required this.recipientId,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': 'share',
    'id': id,
    'title': title,
    'body': body,
    'scheduledTime': scheduledTime.toIso8601String(),
    'friendName': friendName,
    'recipeName': recipeName,
    'senderId': senderId,
    'recipientId': recipientId,    
  };

  static ShareNotification fromJson(Map<String, dynamic> json) {
    return ShareNotification(
      id: json['id'] ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime'] ?? json['createdAt']),
      friendName: json['friendName'] as String?,
      recipeName: json['recipeName'] as String?,
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',      
    );
  }
}