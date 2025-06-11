import 'package:drift/drift.dart';

class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get dataJson => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}