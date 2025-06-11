import 'package:drift/drift.dart';

class FridgeIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get imageURL => text().nullable()();
  BoolColumn get isInFridge => boolean().withDefault(const Constant(false))();
  TextColumn get fridgeId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}