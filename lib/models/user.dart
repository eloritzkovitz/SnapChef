class User {
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final String fridgeId;
  final String cookbookId;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    required this.fridgeId,
    required this.cookbookId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'User',
      email: json['email'] ?? 'No Email',
      profilePicture: json['profilePicture']?.isNotEmpty == true ? json['profilePicture'] : null,
      fridgeId: json['fridgeId'] ?? 'No Fridge ID',
      cookbookId: json['cookbookId'] ?? 'No Cookbook ID',
    );
  }

  String get fullName => '$firstName $lastName';
}