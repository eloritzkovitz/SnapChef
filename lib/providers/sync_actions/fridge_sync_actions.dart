import '../../models/ingredient.dart';
import '../../services/fridge_service.dart';

/// Handles fridge-related sync actions.
class FridgeSyncActions {
  final FridgeService fridgeService;

  FridgeSyncActions(this.fridgeService);

  /// Processes a fridge action based on the action type.
  Future<void> handleFridgeAction(Map<String, dynamic> action) async {
    switch (action['action']) {
      case 'add':
        await _addFridgeItem(action);
        break;
      case 'update':
        await _updateFridgeItem(action);
        break;
      case 'delete':
        await _deleteFridgeItem(action);
        break;
      case 'reorder':
        await _reorderFridgeItems(action);
        break;
      default:
        break;
    }
  }

  /// Adds a fridge item based on the action details.
  Future<void> _addFridgeItem(Map<String, dynamic> action) async {
    final ingredient =
        Ingredient.fromJson(action['ingredient'] as Map<String, dynamic>);
    final fridgeId = action['fridgeId'] as String;
    final itemData = {
      'id': ingredient.id,
      'name': ingredient.name,
      'category': ingredient.category,
      'imageURL': ingredient.imageURL,
      'quantity': ingredient.count,
    };
    await fridgeService.addFridgeItem(fridgeId, itemData);
  }

  /// Updates a fridge item based on the action details.
  Future<void> _updateFridgeItem(Map<String, dynamic> action) async {
    await fridgeService.updateFridgeItem(
      action['fridgeId'],
      action['itemId'],
      action['newCount'],
    );
  }

  /// Deletes a fridge item based on the action details.
  Future<void> _deleteFridgeItem(Map<String, dynamic> action) async {
    await fridgeService.deleteFridgeItem(
      action['fridgeId'],
      action['itemId'],
    );
  }

  /// Reorders fridge items based on the action details.
  Future<void> _reorderFridgeItems(Map<String, dynamic> action) async {
    await fridgeService.saveFridgeOrder(
      action['fridgeId'],
      List<String>.from(action['orderedIds']),
    );
  }
}
