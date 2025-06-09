import 'package:drift/drift.dart';

class Friends extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get friendId => text()();
  TextColumn get friendName => text()(); 
  TextColumn get friendEmail => text()();
  TextColumn get friendProfilePicture => text().nullable()(); 
  TextColumn get friendJoinDate => text().nullable()(); 
}