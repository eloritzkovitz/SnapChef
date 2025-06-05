import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables/user_table.dart';
import 'tables/ingredient_table.dart';
import 'tables/fridge_ingredient_table.dart';
import 'tables/recipe_table.dart';
import 'tables/shared_recipe_table.dart';
import 'tables/friend_table.dart';
import 'tables/notification_table.dart';

import 'daos/user_dao.dart';
import 'daos/ingredient_dao.dart';
import 'daos/fridge_ingredient_dao.dart';
import 'daos/recipe_dao.dart';
import 'daos/shared_recipe_dao.dart';
import 'daos/friend_dao.dart';
import 'daos/notification_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Ingredients,
  FridgeIngredients,
  Recipes,
  SharedRecipes,
  Friends,
  Notifications  
], daos: [
  UserDao,
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'snapchef.sqlite'));
    return NativeDatabase(file);
  });
}
