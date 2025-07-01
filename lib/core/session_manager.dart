import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../utils/token_util.dart';
import '../viewmodels/cookbook_viewmodel.dart';
import '../viewmodels/fridge_viewmodel.dart';
import '../viewmodels/friend_viewmodel.dart';
import '../viewmodels/ingredient_viewmodel.dart';
import '../viewmodels/main_viewmodel.dart';
import '../viewmodels/notifications_viewmodel.dart';
import '../viewmodels/recipe_viewmodel.dart';
import '../viewmodels/shared_recipe_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';

class SessionManager {
  /// Prepares a new session: resets main tab and navigates to main screen.
  static void createSession(BuildContext context) {
    GetIt.I<MainViewModel>().clear();
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
  }
  
  /// Clears all user session data: database, preferences, tokens, and viewmodels.
  static Future<void> clearSession() async {
    // Clear local database
    final db = GetIt.I<AppDatabase>();
    await db.clearAllTables();

    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear tokens
    await TokenUtil.clearTokens();

    // Clear all relevant viewmodels
    GetIt.I<MainViewModel>().clear();
    GetIt.I<UserViewModel>().clear();
    GetIt.I<IngredientViewModel>().clear();  
    GetIt.I<FridgeViewModel>().clear();
    GetIt.I<RecipeViewModel>().clear();
    GetIt.I<SharedRecipeViewModel>().clear();
    GetIt.I<CookbookViewModel>().clear();    
    GetIt.I<FriendViewModel>().clear();
    GetIt.I<NotificationsViewModel>().clear();
  }
}