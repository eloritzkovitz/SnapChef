import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_actions/fridge_sync_actions.dart';
import '../providers/sync_actions/grocery_sync_actions.dart';
import 'sync_actions/notification_sync_actions.dart';

final getIt = GetIt.instance;

class SyncProvider extends ChangeNotifier {
  /// Map of action queue names to their pending actions.
  final Map<String, List<Map<String, dynamic>>> pendingActionQueues = {};

  // Get sync actions
  FridgeSyncActions get fridgeSyncActions => getIt<FridgeSyncActions>();
  GrocerySyncActions get grocerySyncActions => getIt<GrocerySyncActions>();
  NotificationSyncActions get notificationSyncActions => getIt<NotificationSyncActions>();

  ConnectivityProvider? _syncConnectivityProvider;

  /// Initializes the connectivity provider for syncing actions.
  void initSync(ConnectivityProvider connectivityProvider) {
    _syncConnectivityProvider = connectivityProvider;
    connectivityProvider.addListener(_onConnectivityChanged);

    // Immediately check current status and sync if online
    if (!_syncConnectivityProvider!.isOffline) {
      syncPendingActions();
    }
  }

  /// Disposes the connectivity provider when no longer needed.
  void disposeSync() {
    _syncConnectivityProvider?.removeListener(_onConnectivityChanged);
    _syncConnectivityProvider = null;
  }

  /// Called when connectivity changes.
  void _onConnectivityChanged() {
    if (_syncConnectivityProvider != null &&
        !_syncConnectivityProvider!.isOffline) {
      syncPendingActions();
    }
  }

  /// Adds an action to a specific queue.
  void addPendingAction(String queue, Map<String, dynamic> action) {
    pendingActionQueues.putIfAbsent(queue, () => []);
    pendingActionQueues[queue]!.add(action);
    savePendingActions();
    log('Action added to $queue: $action');
    notifyListeners();
  }

  /// Clears the pending actions queue.
  void clearSyncQueue() {
    pendingActionQueues.clear();
    savePendingActions();
    notifyListeners();
  }

  /// Handles sync action based on the queue type.
  Future<void> handleSyncAction(
      String queue, Map<String, dynamic> action) async {
    switch (queue) {
      case 'fridge':
        await fridgeSyncActions.handleFridgeAction(action);
        break;
      case 'grocery':
        await grocerySyncActions.handleGroceryAction(action);
        break;
      case 'notifications':
       await notificationSyncActions.handleNotificationAction(action);
        break;
      default:
        log('Unknown queue: $queue');
    }
  }

  /// Syncs all pending actions in all queues.
  Future<void> syncPendingActions() async {
    for (final queue in pendingActionQueues.keys) {
      final actions = pendingActionQueues[queue];
      if (actions != null && actions.isNotEmpty) {
        for (final action in List<Map<String, dynamic>>.from(actions)) {
          try {
            await handleSyncAction(queue, action);
            actions.remove(action);
          } catch (e) {
            log('Failed to sync action in $queue: $e');
            break;
          }
        }
      }
    }
    savePendingActions();
    notifyListeners();
  }

  /// Saves pending actions to shared preferences.
  Future<void> savePendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('pendingActions', jsonEncode(pendingActionQueues));
  }

  /// Loads pending actions from shared preferences.
  Future<void> loadPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('pendingActions');
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      pendingActionQueues.clear();
      decoded.forEach((key, value) {
        pendingActionQueues[key] = List<Map<String, dynamic>>.from(value);
      });
    }
    notifyListeners();
  }
}
