import 'package:drift/drift.dart';

class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  TextColumn get imageURL => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}