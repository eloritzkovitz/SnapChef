import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class CookbookService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';
  final AuthService _authService = AuthService();

  // Fetch all recipes in the cookbook
  Future<List<dynamic>> fetchCookbookRecipes() async {
    final token = await _authService.getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/cookbook/recipes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch cookbook recipes: ${response.statusCode}');
    }
  }

  // Add a new recipe to the cookbook
  Future<bool> addRecipeToCookbook(Map<String, dynamic> recipeData) async {
    final token = await _authService.getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/cookbook/recipes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(recipeData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to add recipe to cookbook: ${response.statusCode}');
    }
  }

  // Update a recipe in the cookbook
  Future<bool> updateCookbookRecipe(String recipeId, Map<String, dynamic> updatedData) async {
    final token = await _authService.getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/cookbook/recipes/$recipeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update cookbook recipe: ${response.statusCode}');
    }
  }

  // Delete a recipe from the cookbook
  Future<bool> deleteCookbookRecipe(String recipeId) async {
    final token = await _authService.getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/cookbook/recipes/$recipeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete cookbook recipe: ${response.statusCode}');
    }
  }
}