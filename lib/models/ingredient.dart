class Ingredient {
  final String id;
  final String name;
  final String category;
  final String imageURL;
  int count;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.imageURL,
    this.count = 0,
  });

  // Convert from JSON, ensuring `_id` is mapped to `id`
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['_id'] ?? json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageURL: json['imageURL'] as String,
      count: json['count'] as int? ?? 0,
    );
  }

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