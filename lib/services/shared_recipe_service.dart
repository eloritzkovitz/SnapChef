import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/shared_recipe.dart';
import '../utils/token_util.dart';

class SharedRecipeService {
  final String baseUrl = dotenv.env['SERVER_IP'] ?? '';  

  // Fetch shared recipes
  Future<Map<String, List<SharedRecipe>>> fetchSharedRecipes(
      String cookbookId) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/cookbook/$cookbookId/shared'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sharedWithMeList = data['sharedWithMe'] as List<dynamic>;
      final sharedByMeList = data['sharedByMe'] as List<dynamic>;
      return {
        'sharedWithMe': sharedWithMeList
            .map((json) => SharedRecipe.fromJson(json))
            .toList(),
        'sharedByMe':
            sharedByMeList.map((json) => SharedRecipe.fromJson(json)).toList(),
      };
    } else {
      throw Exception('Failed to fetch shared recipes');
    }
  }

  // Delete a shared recipe
  Future<void> deleteSharedRecipe(String cookbookId, String sharedRecipeId) async {
    final token = await TokenUtil.getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/cookbook/$cookbookId/shared/$sharedRecipeId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove shared recipe');
    }
  }  
}
