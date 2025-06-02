class Ingredient {
  final String id;
  final String name;
  final String category;
  String imageURL;
  int count;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.imageURL,
    required this.count,
  });

  // Convert JSON to Ingredient object
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      imageURL: json['imageURL'] ?? 'assets/images/placeholder_image.png',
      count: json['count'] ?? 0,
    );
  }

  // Convert Ingredient object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageURL': imageURL,
      'count': count,
    };
  }
}