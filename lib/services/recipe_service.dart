import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/token_util.dart';

class RecipeService {
  final String? serverUrl = dotenv.env['SERVER_IP'];

  // Generate a recipe based on the provided payload
  Future<Map<String, String>> generateRecipe(
      Map<String, dynamic> payload) async {
    if (serverUrl == null) {
      throw Exception("Server URL not configured properly.");
    }

    final token = await TokenUtil.getAccessToken();

    final response = await http.post(
      Uri.parse("$serverUrl/api/recipes/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'recipe': data['recipe']?['raw'] ?? 'No recipe found.',
        'imageUrl': data['imageUrl'] ?? '',
      };
    } else {
      throw Exception('Failed to generate recipe: ${response.body}');
    }
  }

  // Regenerate a recipe image using the provided payload
  Future<String> regenerateRecipeImage(Map<String, dynamic> payload) async {
    if (serverUrl == null) {
      throw Exception("Server URL not configured properly.");
    }

    final token = await TokenUtil.getAccessToken();

    final response = await http.post(
      Uri.parse("$serverUrl/api/recipes/image"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['imageUrl'] ?? '';
    } else {
      throw Exception('Failed to regenerate recipe image: ${response.body}');
    }
  }
}
