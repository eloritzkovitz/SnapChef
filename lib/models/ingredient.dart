import '../database/app_database.dart' as db;
import 'package:drift/drift.dart';
import '../database/app_database.dart';

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

  // Create a copy of Ingredient with optional new values
  Ingredient copyWith({
    String? id,
    String? name,
    String? category,
    String? imageURL,
    int? count,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageURL: imageURL ?? this.imageURL,
      count: count ?? this.count,
    );
  }

  // Convert Ingredient to Drift DB object
  db.FridgeIngredient toDbFridgeIngredient({required String fridgeId, bool isInFridge = true}) {
    return db.FridgeIngredient(
      id: id,
      fridgeId: fridgeId,
      name: name,
      category: category,
      imageURL: imageURL,
      count: count,
      isInFridge: isInFridge,
    );
  }

  // Factory to create Ingredient from Drift DB object
  factory Ingredient.fromDb(db.FridgeIngredient dbIng) {
    return Ingredient(
      id: dbIng.id,
      name: dbIng.name,
      category: dbIng.category ?? 'Unknown',
      imageURL: dbIng.imageURL ?? 'assets/images/placeholder_image.png',
      count: dbIng.count,      
    );
  } 
}

extension IngredientDbExtension on Ingredient {
  IngredientsCompanion toCompanion() {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      imageURL: Value(imageURL),      
    );
  }
}