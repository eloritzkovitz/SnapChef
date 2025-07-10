import 'dart:ui';
import 'package:mockito/mockito.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_actions/cookbook_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/fridge_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/grocery_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/notification_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/shared_recipe_sync_actions.dart';
import 'package:snapchef/providers/sync_provider.dart';

class MockSyncProvider extends Mock implements SyncProvider {
  @override
  void initSync(ConnectivityProvider connectivityProvider) {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  void addPendingAction(String queue, Map<String, dynamic> action) {}

  @override
  void clearSyncQueue() {}

  @override
  CookbookSyncActions get cookbookSyncActions => throw UnimplementedError();

  @override
  void dispose() {}

  @override
  void disposeSync() {}

  @override
  FridgeSyncActions get fridgeSyncActions => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getPendingActions(String queue) async => [];

  @override
  GrocerySyncActions get grocerySyncActions => throw UnimplementedError();

  @override
  Future<void> handleSyncAction(String queue, Map<String, dynamic> action) async {}

  @override
  bool get hasListeners => false;

  @override
  Future<void> loadPendingActions() async {}

  @override
  NotificationSyncActions get notificationSyncActions => throw UnimplementedError();

  @override
  void notifyListeners() {}

  @override
  Map<String, List<Map<String, dynamic>>> get pendingActionQueues => {};

  @override
  void removeListener(VoidCallback listener) {}

  @override
  Future<void> savePendingActions() async {}

  @override
  SharedRecipeSyncActions get sharedRecipeSyncActions => throw UnimplementedError();

  @override
  Future<void> syncPendingActions() async {}
}