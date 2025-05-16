import 'ingredient.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String mealType;
  final String cuisineType;
  final String difficulty;
  final int prepTime;
  final int cookingTime;  
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final String? imageURL;
  final double? rating;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.mealType,
    required this.cuisineType,
    required this.difficulty,
    required this.prepTime,
    required this.cookingTime,    
    required this.ingredients,
    required this.instructions,
    this.imageURL,
    this.rating,
  });

  // Factory method to create a Recipe from JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      mealType: json['mealType'],
      cuisineType: json['cuisineType'],
      difficulty: json['difficulty'],
      prepTime: json['prepTime'],
      cookingTime: json['cookingTime'],      
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((ingredient) => Ingredient.fromJson(ingredient))
          .toList(),
      instructions: List<String>.from(json['instructions']),
      imageURL: json['imageURL'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  // Method to convert a Recipe to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'mealType': mealType,
      'cuisineType': cuisineType,
      'difficulty': difficulty,      
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'instructions': instructions,
      'imageURL': imageURL,
      'rating': rating,
    };
  }
}