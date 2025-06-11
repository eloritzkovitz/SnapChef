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

  // Update the image URL of a fridge item
  Future<bool> updateFridgeItemImageURL(
      String fridgeId, String itemId, String imageURL) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/items/$itemId/image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'imageURL': imageURL}),
    );
    return response.statusCode == 200;
  }

  // Save the new fridge order to the backend
  Future<void> saveFridgeOrder(
      String fridgeId, List<String> orderedIngredientIds) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/items/reorder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'orderedItemIds': orderedIngredientIds}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save fridge order: ${response.body}');
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

  // Update a grocery item
  Future<bool> updateGroceryItem(
      String fridgeId, String itemId, int newCount) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/groceries/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'quantity': newCount}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update grocery item: ${response.statusCode}');
    }
  }

  // Update the image URL of a grocery item
  Future<bool> updateGroceryItemImageURL(
      String fridgeId, String itemId, String imageURL) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/groceries/$itemId/image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'imageURL': imageURL}),
    );
    return response.statusCode == 200;
  }

  // Save the new fridge order to the backend
  Future<void> saveGroceriesOrder(
      String fridgeId, List<String> orderedGroceriesIds) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/fridge/$fridgeId/groceries/reorder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'orderedItemIds': orderedGroceriesIds}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save fridge order: ${response.body}');
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
