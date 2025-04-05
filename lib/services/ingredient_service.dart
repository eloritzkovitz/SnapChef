import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IngredientService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  // Fetch all ingredients
  Future<List<dynamic>> getAllIngredients() async {
    final url = Uri.parse('$baseUrl/api/ingredients/');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch all ingredients');
    }
  }

  // Fetch ingredients by query (name or category)
  Future<List<dynamic>> searchIngredients({String? name, String? category}) async {
    // Build the query parameters
    final queryParams = {
      if (name != null) 'name': name,
      if (category != null) 'category': category,
    };

    // Construct the URL with query parameters
    final url = Uri.parse('$baseUrl/api/ingredients/').replace(queryParameters: queryParams);

    // Make the GET request
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else if (response.statusCode == 404) {
      return []; // Return an empty list if no ingredients are found
    } else {
      throw Exception('Failed to fetch ingredients');
    }
  }

  // Fetch a specific ingredient by ID
  Future<Map<String, dynamic>> getIngredientById(String id) async {
    final url = Uri.parse('$baseUrl/api/ingredients/$id');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 400) {
      throw Exception('ID parameter is required');
    } else if (response.statusCode == 404) {
      throw Exception('Ingredient not found');
    } else {
      throw Exception('Failed to fetch ingredient');
    }
  }
}