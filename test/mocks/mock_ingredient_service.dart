import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/models/ingredient.dart';

class MockIngredientService implements IngredientService {
  @override
  Future<List<Ingredient>> getAllIngredients() async {
    // Return an empty list or mock Ingredient objects as needed
    return [];
  }

  @override
  Future<List<Ingredient>> searchIngredients({String? name, String? category}) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getIngredientById(String id) async {
    // Return a mock Ingredient as a map
    return {
      'id': id,
      'name': 'Mock Ingredient',
      'category': 'Mock Category',
      'count': 1,
      'imageURL': '',
    };
  }

  @override
  String get baseUrl => 'https://mock.url';
}