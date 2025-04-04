import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/ingredient.dart';
import '../services/upload_photo.dart';

class FridgeViewModel extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];
  List<dynamic> recognizedIngredients = [];

  String _filter = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  List<Ingredient> get filteredIngredients {
    if (_filter.isEmpty) {
      return _ingredients;
    }
    return _ingredients
        .where((ingredient) => ingredient.name.toLowerCase().contains(_filter.toLowerCase()))
        .toList();
  }

  // Fetch ingredients from the user's fridge
  Future<void> fetchFridgeIngredients(String fridgeId) async {
    String? serverIp = dotenv.env['SERVER_IP'];
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$serverIp/api/fridge/$fridgeId/items'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        _ingredients.clear();
        if (jsonResponse.isNotEmpty) {
          _ingredients.addAll(
            jsonResponse.map((item) {
              return Ingredient(
                id: item['id'],
                name: item['name'],
                category: item['category'],
                imageURL: item['imageURL'] ?? 'assets/images/placeholder_image.png',
                count: item['quantity'],
              );
            }).toList(),
          );
        }
      } else {
        log('Failed to fetch fridge ingredients: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching fridge ingredients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process an image and recognize ingredients
  Future<void> recognizeIngredients(File image, String endpoint) async {
    _isLoading = true;
    recognizedIngredients = [];
    notifyListeners();

    try {
      final uploadPhoto = UploadPhoto();
      recognizedIngredients = await uploadPhoto.processImage(image, endpoint);
    } catch (e) {
      log('Error recognizing ingredients: $e');
      recognizedIngredients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add ingredient to fridge (local and backend)
  Future<bool> addIngredientToFridge(String fridgeId, String id, String name, String category, int quantity) async {
    String? serverIp = dotenv.env['SERVER_IP'];

    try {
      final response = await http.post(
        Uri.parse('$serverIp/api/fridge/$fridgeId/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'name': name,
          'category': category,
          'imageURL': '',
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final newItem = jsonResponse['ingredient'];

        _ingredients.add(
          Ingredient(
            id: newItem['id'],
            name: newItem['name'],
            category: newItem['category'],
            imageURL: newItem['imageURL'] ?? '',
            count: newItem['quantity'],
          ),
        );
        notifyListeners();
        return true;
      } else {
        log('Failed to add ingredient to fridge: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error adding ingredient to fridge: $e');
      return false;
    }
  }

  // Update ingredient count in fridge (local and backend)
  Future<bool> updateItem(String fridgeId, String itemId, int newCount) async {
    String? serverIp = dotenv.env['SERVER_IP'];

    try {
      final response = await http.put(
        Uri.parse('$serverIp/api/fridge/$fridgeId/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': newCount}),
      );

      if (response.statusCode == 200) {
        final index = _ingredients.indexWhere((ingredient) => ingredient.id == itemId);
        if (index != -1) {
          _ingredients[index].count = newCount;
          notifyListeners();
        }
        return true;
      } else {
        log('Failed to update item: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error updating item: $e');
      return false;
    }
  }

  // Delete ingredient from fridge (local and backend)
  Future<bool> deleteItem(String fridgeId, String itemId) async {
    String? serverIp = dotenv.env['SERVER_IP'];

    try {
      final response = await http.delete(
        Uri.parse('$serverIp/api/fridge/$fridgeId/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _ingredients.removeWhere((ingredient) => ingredient.id == itemId);
        notifyListeners();
        return true;
      } else {
        log('Failed to delete item: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error deleting item: $e');
      return false;
    }
  }

  // Set filter for searching ingredients
  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  // Increase ingredient count
  void increaseCount(int index, String fridgeId) async {
    final ingredient = _ingredients[index];
    final newCount = ingredient.count + 1;

    final success = await updateItem(fridgeId, ingredient.id, newCount);
    if (success) {
      ingredient.count = newCount;
      notifyListeners();
    }
  }

  // Decrease ingredient count
  void decreaseCount(int index, String fridgeId) async {
    final ingredient = _ingredients[index];
    if (ingredient.count > 0) {
      final newCount = ingredient.count - 1;

      final success = await updateItem(fridgeId, ingredient.id, newCount);
      if (success) {
        ingredient.count = newCount;
        notifyListeners();
      }
    }
  }
}