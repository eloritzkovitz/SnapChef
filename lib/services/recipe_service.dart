import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeService {
  final String? serverUrl = dotenv.env['SERVER_IP'];

  Future<Map<String, String>> generateRecipe(String ingredients) async {
    if (serverUrl == null) {
      throw Exception("Server URL not configured properly.");
    }

    final response = await http.post(
      Uri.parse("$serverUrl/api/recipes/generate"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ingredients': ingredients,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'recipe': data['recipe'] ?? 'No recipe found.',
        'imageUrl': data['imageUrl'] ?? '',
      };
    } else {
      throw Exception('Failed to generate recipe.');
    }
  }
}