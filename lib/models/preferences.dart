class Preferences {
  final List<String> allergies;
  final Map<String, bool> dietaryPreferences;

  Preferences({
    required this.allergies,
    required this.dietaryPreferences,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      allergies: List<String>.from(json['allergies'] ?? []),
      dietaryPreferences: Map<String, bool>.from(json['dietaryPreferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'allergies': allergies,
        'dietaryPreferences': dietaryPreferences,
      };
}