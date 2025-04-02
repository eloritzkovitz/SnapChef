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
    required this.count,
  });  

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