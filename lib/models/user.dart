class User {
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'User',
      email: json['email'] ?? 'No Email',
      profilePicture: json['profilePicture']?.isNotEmpty == true ? json['profilePicture'] : null,
    );
  }

  String get fullName => '$firstName $lastName';
}