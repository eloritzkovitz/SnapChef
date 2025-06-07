import 'package:flutter/foundation.dart';
import 'dart:developer';
import '../models/ingredient.dart';
import '../services/fridge_service.dart';
import '../providers/connectivity_provider.dart';

mixin FridgeSyncMixin on ChangeNotifier {
  FridgeService get fridgeService;

  // Pending actions for fridge items  
  final List<Map<String, dynamic>> pendingFridgeActions = [];
  final List<Map<String, dynamic>> pendingGroceryActions = [];
  final List<Map<String, dynamic>> pendingFridgeOrderActions = [];
  final List<Map<String, dynamic>> pendingGroceryOrderActions = [];  

  ConnectivityProvider? _fridgeSyncConnectivityProvider;

  // Initialize the connectivity provider for fridge sync
  void initFridgeSync(ConnectivityProvider connectivityProvider) {
    _fridgeSyncConnectivityProvider = connectivityProvider;
    connectivityProvider.addListener(_onConnectivityChanged);
  }

  // Dispose the connectivity provider when no longer needed
  void disposeFridgeSync() {
    _fridgeSyncConnectivityProvider?.removeListener(_onConnectivityChanged);
    _fridgeSyncConnectivityProvider = null;
  }

  // Sync pending fridge actions when connectivity changes
  void _onConnectivityChanged() {
    if (_fridgeSyncConnectivityProvider != null &&
        !_fridgeSyncConnectivityProvider!.isOffline) {
      syncPendingActions();
    }
  }

  // --- Sync logic ---
  Future<void> syncPendingActions() async {
    // Sync fridge actions (add/update/delete)
    if (pendingFridgeActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(pendingFridgeActions)) {
        try {
          switch (action['action']) {
            case 'add':
              final ingredient = action['ingredient'] as Ingredient;
              final fridgeId = action['fridgeId'] as String;
              final itemData = {
                'id': ingredient.id,
                'name': ingredient.name,
                'category': ingredient.category,
                'imageURL': ingredient.imageURL,
                'quantity': ingredient.count,
              };
              await fridgeService.addFridgeItem(fridgeId, itemData);
              break;
            case 'update':
              await fridgeService.updateFridgeItem(
                action['fridgeId'],
                action['itemId'],
                action['newCount'],
              );
              break;
            case 'delete':
              await fridgeService.deleteFridgeItem(
                action['fridgeId'],
                action['itemId'],
              );
              break;
          }
          pendingFridgeActions.remove(action);
        } catch (e) {
          log('Failed to sync fridge action: $e');
          break;
        }
      }
    }

    // Sync fridge reorder actions
    if (pendingFridgeOrderActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(pendingFridgeOrderActions)) {
        try {
          if (action['action'] == 'reorder') {
            await fridgeService.saveFridgeOrder(
              action['fridgeId'],
              List<String>.from(action['orderedIds']),
            );
          }
          pendingFridgeOrderActions.remove(action);
        } catch (e) {
          log('Failed to sync fridge order: $e');
          break;
        }
      }
    }

    // Sync grocery actions (add/update/delete)
    if (pendingGroceryActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(pendingGroceryActions)) {
        try {
          switch (action['action']) {
            case 'add':
              final ingredient = action['ingredient'] as Ingredient;
              final fridgeId = action['fridgeId'] as String;
              final itemData = {
                'id': ingredient.id,
                'name': ingredient.name,
                'category': ingredient.category,
                'imageURL': ingredient.imageURL,
                'quantity': ingredient.count,
              };
              await fridgeService.addGroceryItem(fridgeId, itemData);
              break;
            case 'update':
              await fridgeService.updateGroceryItem(
                action['fridgeId'],
                action['itemId'],
                action['newCount'],
              );
              break;
            case 'delete':
              await fridgeService.deleteGroceryItem(
                action['fridgeId'],
                action['itemId'],
              );
              break;
          }
          pendingGroceryActions.remove(action);
        } catch (e) {
          log('Failed to sync grocery action: $e');
          break;
        }
      }
    }

    // Sync grocery reorder actions
    if (pendingGroceryOrderActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(pendingGroceryOrderActions)) {
        try {
          if (action['action'] == 'reorder') {
            await fridgeService.saveGroceriesOrder(
              action['fridgeId'],
              List<String>.from(action['orderedIds']),
            );
          }
          pendingGroceryOrderActions.remove(action);
        } catch (e) {
          log('Failed to sync groceries order: $e');
          break;
        }
      }
    }

    notifyListeners();
  }
}