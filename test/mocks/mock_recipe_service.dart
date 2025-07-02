import 'package:snapchef/services/recipe_service.dart';

class MockRecipeService extends RecipeService {
  @override
  Future<Map<String, String>> generateRecipe(Map<String, dynamic> payload) async {
    // Return a predictable mock response
    return {
      'recipe': 'Mocked recipe for ${payload['ingredients'] ?? 'unknown ingredients'}.',
      'imageUrl': 'https://example.com/mock-image.jpg',
    };
  }

  @override
  Future<String> regenerateRecipeImage(Map<String, dynamic> payload) async {
    // Return a predictable mock image URL
    return 'https://example.com/mock-regenerated-image.jpg';
  }
}