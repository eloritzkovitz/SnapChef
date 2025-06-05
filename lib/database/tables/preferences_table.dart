import 'package:drift/drift.dart';

class Preferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get allergies => text().nullable()();
  TextColumn get dietaryPreferences => text().nullable()(); 
  TextColumn get notificationPreferences => text().nullable()();
}