import 'package:drift/drift.dart';

class UserStats extends Table {
  TextColumn get userId => text()();
  IntColumn get ingredientCount => integer().nullable()();
  IntColumn get recipeCount => integer().nullable()();
  IntColumn get favoriteRecipeCount => integer().nullable()();
  IntColumn get friendCount => integer().nullable()();
  TextColumn get mostPopularIngredients => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}