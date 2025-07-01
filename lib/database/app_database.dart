import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables/user_table.dart';
import 'tables/user_stats_table.dart';
import 'tables/ingredient_table.dart';
import 'tables/fridge_ingredient_table.dart';
import 'tables/recipe_table.dart';
import 'tables/shared_recipe_table.dart';
import 'tables/friend_table.dart';
import 'tables/notification_table.dart';

import 'daos/user_dao.dart';
import 'daos/user_stats_dao.dart';
import 'daos/ingredient_dao.dart';
import 'daos/fridge_ingredient_dao.dart';
import 'daos/recipe_dao.dart';
import 'daos/shared_recipe_dao.dart';
import 'daos/friend_dao.dart';
import 'daos/notification_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  UserStats,
  Ingredients,
  FridgeIngredients,
  Recipes,
  SharedRecipes,
  Friends,
  Notifications
], daos: [
  UserDao,
  UserStatsDao,
  IngredientDao,
  FridgeIngredientDao,
  RecipeDao,
  SharedRecipeDao,
  FriendDao,
  NotificationDao
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Clears all user/session data from every table.
  Future<void> clearAllTables() async {
    // Order matters if you have foreign keys!
    await batch((batch) {
      batch.deleteAll(users);
      batch.deleteAll(userStats);
      batch.deleteAll(ingredients);
      batch.deleteAll(fridgeIngredients);
      batch.deleteAll(recipes);
      batch.deleteAll(sharedRecipes);
      batch.deleteAll(friends);
      batch.deleteAll(notifications);
    });
  }
}

/// Opens a connection to the SQLite database.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'snapchef.sqlite'));
    return NativeDatabase(file);
  });  
}
