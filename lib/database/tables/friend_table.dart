import 'package:drift/drift.dart';

class Friends extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get friendId => text()();
  TextColumn get status => text().withDefault(const Constant('accepted'))();
}