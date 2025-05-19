class Friend {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final String? joinDate;

  Friend({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    this.joinDate,    
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'User',
      email: json['email'] ?? 'No Email',
      profilePicture: json['profilePicture']?.isNotEmpty == true ? json['profilePicture'] : null,
      joinDate: json['joinDate'],      
    );
  }

  String get fullName => '$firstName $lastName';
}