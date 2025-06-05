import 'package:drift/drift.dart';

class SharedRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get fromUser => text()();
  TextColumn get toUser => text()();
  TextColumn get sharedAt => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
}