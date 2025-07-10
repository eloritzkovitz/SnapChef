import 'package:snapchef/database/app_database.dart';

class MockAppDatabase extends AppDatabase {
  @override
  Future<void> clearAllTables() async {
    // Do nothing, just mock the method
  }
}