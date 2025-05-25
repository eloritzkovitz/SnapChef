import '../../models/user.dart';

class FriendRequest {
  final String id;
  final User from; // Populated user object
  final String to; // Just a user ID
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.from,
    required this.to,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic id) {
      if (id is Map && id.containsKey('\$oid')) {
        return id['\$oid'] as String;
      }
      return id as String;
    }

    return FriendRequest(
      id: parseId(json['_id']),
      from: User.fromJson(json['from']),
      to: json['to'] is Map ? parseId(json['to']) : json['to'],
      status: json['status'] as String,
      createdAt: DateTime.parse(
        json['createdAt'] is Map && json['createdAt'].containsKey('\$date')
            ? json['createdAt']['\$date']
            : json['createdAt'],
      ),
    );
  }
}