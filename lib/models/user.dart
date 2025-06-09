import 'dart:convert';
import '../database/app_database.dart' as db;
import 'preferences.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? profilePicture;
  final DateTime? joinDate;
  final String fridgeId;
  final String cookbookId;
  final Preferences? preferences;
  final List<User> friends;
  final String? fcmToken;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.profilePicture,
    this.joinDate,
    required this.fridgeId,
    required this.cookbookId,
    this.preferences,
    this.friends = const [],
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic id) {
      if (id is Map && id.containsKey('\$oid')) {
        return id['\$oid'] as String;
      }
      return id as String;
    }

    return User(
      id: parseId(json['_id'] ?? json['id'] ?? ''),
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'User',
      email: json['email'] ?? 'No Email',
      profilePicture: json['profilePicture']?.isNotEmpty == true
          ? json['profilePicture']
          : null,
      joinDate: json['joinDate'] != null && json['joinDate'] != 'No date available'
    ? DateTime.tryParse(json['joinDate'])
    : null,
      fridgeId: json['fridgeId'] ?? 'No Fridge ID',
      cookbookId: json['cookbookId'] ?? 'No Cookbook ID',
      preferences: json['preferences'] != null
          ? Preferences.fromJson(json['preferences'])
          : null,
      friends: (json['friends'] as List<dynamic>?)?.map((friend) {
            if (friend is Map<String, dynamic>) {
              return User.fromJson(friend);
            } else if (friend is String) {             
              return User(
                id: friend,
                firstName: 'Unknown',
                lastName: 'User',
                email: '',
                fridgeId: '',
                cookbookId: '',
              );
            } else {
              throw Exception('Unknown friend type: $friend');
            }
          }).toList() ??
          [],
      fcmToken: json['fcmToken'],
    );
  }

  // Method to convert User object to JSON
  User copyWith({
    String? firstName,
    String? lastName,
    String? password,
    String? profilePicture,
    DateTime? joinDate,
    String? fridgeId,
    String? cookbookId,
    Preferences? preferences,
    List<User>? friends,
    String? fcmToken,
  }) {
    return User(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
      joinDate: joinDate ?? this.joinDate,
      fridgeId: fridgeId ?? this.fridgeId,
      cookbookId: cookbookId ?? this.cookbookId,
      preferences: preferences ?? this.preferences,
      friends: friends ?? this.friends,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Concatenate first and last name
  String get fullName => '$firstName $lastName';

  // Convert User to a Map for saving to a database
  factory User.fromDb(db.User user, {List<User> friends = const []}) {
    return User(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      password: null,
      profilePicture: user.profilePicture,
      joinDate: user.joinDate != null ? DateTime.tryParse(user.joinDate!) : null,
      fridgeId: user.fridgeId,
      cookbookId: user.cookbookId,
      preferences: user.preferencesJson != null
          ? Preferences.fromJson(jsonDecode(user.preferencesJson!))
          : null,
      friends: friends,
      fcmToken: user.fcmToken,
    );
  }

  // Create User from Friend database object
  factory User.fromFriendDb(db.Friend f) {
  return User(
    id: f.friendId,
    firstName: f.friendName.split(' ').first,
    lastName: f.friendName.split(' ').skip(1).join(' '),
    email: f.friendEmail,
    profilePicture: f.friendProfilePicture,
    joinDate: f.friendJoinDate != null ? DateTime.tryParse(f.friendJoinDate!) : null,
    fridgeId: '',
    cookbookId: '',
  );
}
}