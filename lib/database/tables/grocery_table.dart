import 'package:drift/drift.dart';

class Groceries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get category => text().nullable()();
  TextColumn get imageURL => text().nullable()();
  BoolColumn get inFridge => boolean().withDefault(const Constant(false))();
  TextColumn get fridgeId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}