import 'package:drift/drift.dart';

class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get imageURL => text().nullable()();
  TextColumn get recipeId => text().nullable()();
  TextColumn get fridgeId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}