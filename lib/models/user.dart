import 'preferences.dart';
import 'friend.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? profilePicture;
  final String? joinDate;
  final String fridgeId;
  final String cookbookId;
  final Preferences? preferences;
  final List<Friend> friends;
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
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'User',
      email: json['email'] ?? 'No Email',      
      profilePicture: json['profilePicture']?.isNotEmpty == true ? json['profilePicture'] : null,
      joinDate: json['joinDate'] ?? 'No date available',
      fridgeId: json['fridgeId'] ?? 'No Fridge ID',
      cookbookId: json['cookbookId'] ?? 'No Cookbook ID',
      preferences: json['preferences'] != null
          ? Preferences.fromJson(json['preferences'])
          : null,
      friends: (json['friends'] as List<dynamic>?)
              ?.map((friend) => Friend.fromJson(friend)).toList() ?? [],
      fcmToken: json['fcmToken'],
    );
  }

  // Method to convert User object to JSON
  User copyWith({    
    String? firstName,
    String? lastName,
    String? password,
    String? profilePicture,
    String? joinDate,
    String? fridgeId,
    String? cookbookId,
    Preferences? preferences,
    List<Friend>? friends,
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
}