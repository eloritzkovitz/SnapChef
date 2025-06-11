import 'ingredient.dart';
import 'dart:convert';
import '../database/app_database.dart' as db;

enum RecipeSource { ai, user, shared }

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
  final bool isFavorite;
  final RecipeSource source;

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
    this.isFavorite = false,
    required this.source,
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
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      isFavorite: json['isFavorite'] ?? false,
      source: json['source'] == 'ai'
          ? RecipeSource.ai
          : json['source'] == 'shared'
              ? RecipeSource.shared
              : RecipeSource.user,
    );
  }

  // Factory to create a Recipe from a DB map
  factory Recipe.fromDb(Map<String, dynamic> dbRecipe) {
    return Recipe(
      id: dbRecipe['id'] as String,
      title: dbRecipe['title'] as String,
      description: dbRecipe['description'] as String,
      mealType: dbRecipe['mealType'] as String,
      cuisineType: dbRecipe['cuisineType'] as String,
      difficulty: dbRecipe['difficulty'] as String,
      prepTime: dbRecipe['prepTime'] as int,
      cookingTime: dbRecipe['cookingTime'] as int,
      ingredients: dbRecipe['ingredientsJson'] != null
          ? (jsonDecode(dbRecipe['ingredientsJson']) as List)
              .map((i) => Ingredient.fromJson(i))
              .toList()
          : [],
      instructions: dbRecipe['instructionsJson'] != null
          ? List<String>.from(jsonDecode(dbRecipe['instructionsJson']))
          : [],
      imageURL: dbRecipe['imageURL'] as String?,
      rating: dbRecipe['rating'] != null
          ? (dbRecipe['rating'] as num).toDouble()
          : null,
      isFavorite: dbRecipe['isFavorite'] == 1 || dbRecipe['isFavorite'] == true,
      source: dbRecipe['source'] == 'ai'
          ? RecipeSource.ai
          : dbRecipe['source'] == 'shared'
              ? RecipeSource.shared
              : RecipeSource.user,
    );
  }

  // Convert a Recipe to a Map for saving to a database
  Map<String, dynamic> toDbMap({required String cookbookId}) {
    return {
      'id': id,
      'cookbookId': cookbookId,
      'title': title,
      'description': description,
      'mealType': mealType,
      'cuisineType': cuisineType,
      'difficulty': difficulty,
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'imageURL': imageURL,
      'rating': rating,
      'isFavorite': isFavorite ? 1 : 0,
      'source': source == RecipeSource.ai
          ? 'ai'
          : source == RecipeSource.shared
              ? 'shared'
              : 'user',
    };
  }

  // Convert a Recipe to a Drift DB Recipe object (db.Recipe)
  db.Recipe toDbRecipe({required String userId}) {
    return db.Recipe(
      id: id,
      userId: userId,
      title: title,
      description: description,
      mealType: mealType,
      cuisineType: cuisineType,
      difficulty: difficulty,
      prepTime: prepTime,
      cookingTime: cookingTime,
      ingredientsJson: jsonEncode(ingredients.map((i) => i.toJson()).toList()),
      instructionsJson: jsonEncode(instructions),
      imageURL: imageURL ?? '',
      rating: rating,
      isFavorite: isFavorite,
      source: source == RecipeSource.ai
          ? 'ai'
          : source == RecipeSource.shared
              ? 'shared'
              : 'user',
      order: 0,
    );
  }

  // Convert a Recipe to JSON
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
      'ingredients':
          ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'instructions': instructions,
      'imageURL': imageURL,
      'rating': rating,
      'isFavorite': false,
      'source': source == RecipeSource.ai
          ? 'ai'
          : source == RecipeSource.shared
              ? 'shared'
              : 'user',
    };
  }

  // Convert a Recipe to a Map for saving to a database
  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? mealType,
    String? cuisineType,
    String? difficulty,
    int? prepTime,
    int? cookingTime,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    String? imageURL,
    double? rating,
    bool? isFavorite,
    RecipeSource? source,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mealType: mealType ?? this.mealType,
      cuisineType: cuisineType ?? this.cuisineType,
      difficulty: difficulty ?? this.difficulty,
      prepTime: prepTime ?? this.prepTime,
      cookingTime: cookingTime ?? this.cookingTime,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageURL: imageURL ?? this.imageURL,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? false,
      source: source ?? this.source,
    );
  }
}
