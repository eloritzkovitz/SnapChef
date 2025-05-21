import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/token_util.dart';

class FridgeService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';

  // Fetch all fridges for the user
  Future<List<dynamic>> fetchFridgeItems(String fridgeId) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch fridge items: ${response.statusCode}');
    }
  }

  // Add a new fridge item
  Future<bool> addFridgeItem(
      String fridgeId, Map<String, dynamic> itemData) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(itemData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to add fridge item: ${response.statusCode}');
    }
  }

  // Update a fridge item
  Future<bool> updateFridgeItem(
      String fridgeId, String itemId, int newCount) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/items/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'quantity': newCount}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update fridge item: ${response.statusCode}');
    }
  }

  // Delete a fridge item
  Future<bool> deleteFridgeItem(String fridgeId, String itemId) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/items/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete fridge item: ${response.statusCode}');
    }
  }

  // Fetch all grocery items for the fridge
  Future<List<Map<String, dynamic>>> fetchGroceries(String fridgeId) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/groceries'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch groceries: ${response.statusCode}');
    }
  }

  // Add a grocery item
  Future<bool> addGroceryItem(
      String fridgeId, Map<String, dynamic> itemData) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/groceries'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(itemData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to add grocery item: ${response.statusCode}');
    }
  }

  // Delete a grocery item
  Future<bool> deleteGroceryItem(String fridgeId, String itemId) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/groceries/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete grocery item: ${response.statusCode}');
    }
  }
}
