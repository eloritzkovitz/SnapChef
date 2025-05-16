import 'preferences.dart';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? profilePicture;
  final String fridgeId;
  final String cookbookId;
  final Preferences? preferences;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.profilePicture,
    required this.fridgeId,
    required this.cookbookId,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'User',
      email: json['email'] ?? 'No Email',      
      profilePicture: json['profilePicture']?.isNotEmpty == true ? json['profilePicture'] : null,
      fridgeId: json['fridgeId'] ?? 'No Fridge ID',
      cookbookId: json['cookbookId'] ?? 'No Cookbook ID',
      preferences: json['preferences'] != null
          ? Preferences.fromJson(json['preferences'])
          : null,
    );
  }

  // Method to convert User object to JSON
  User copyWith({
    String? firstName,
    String? lastName,
    String? password,
    String? profilePicture,
    String? fridgeId,
    String? cookbookId,
    Preferences? preferences,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
      fridgeId: fridgeId ?? this.fridgeId,
      cookbookId: cookbookId ?? this.cookbookId,
      preferences: preferences ?? this.preferences,
    );
  }

  String get fullName => '$firstName $lastName';
}