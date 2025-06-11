import 'package:drift/drift.dart';

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get mealType => text()();
  TextColumn get cuisineType => text()();
  TextColumn get difficulty => text()();
  IntColumn get prepTime => integer()();
  IntColumn get cookingTime => integer()();
  TextColumn get ingredientsJson => text()();
  TextColumn get instructionsJson => text()();
  TextColumn get imageURL => text().nullable()();
  RealColumn get rating => real().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get source => text()();
  IntColumn get order => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}