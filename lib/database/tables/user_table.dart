import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get email => text()();
  TextColumn get password => text().nullable()();
  TextColumn get profilePicture => text().nullable()();
  TextColumn get joinDate => text().nullable()();
  TextColumn get fridgeId => text()();
  TextColumn get cookbookId => text()();
  TextColumn get preferencesJson => text().nullable()();
  TextColumn get friendsJson => text().nullable()();
  TextColumn get fcmToken => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}