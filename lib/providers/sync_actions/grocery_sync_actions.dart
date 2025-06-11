import '../../models/ingredient.dart';
import '../../services/fridge_service.dart';

/// Handles grocery-related sync actions.
class GrocerySyncActions {
  final FridgeService fridgeService;

  GrocerySyncActions(this.fridgeService);

  /// Processes a grocery action based on the action type.
  Future<void> handleGroceryAction(Map<String, dynamic> action) async {
    switch (action['action']) {
      case 'add':
        await _addGroceryItem(action);
        break;
      case 'update':
        await _updateGroceryItem(action);
        break;
      case 'delete':
        await _deleteGroceryItem(action);
        break;
      case 'reorder':
        await _reorderGroceryItems(action);
        break;
      default:       
        break;
    }
  }

  /// Adds a grocery item based on the action details.
  Future<void> _addGroceryItem(Map<String, dynamic> action) async {
    final ingredient = Ingredient.fromJson(action['ingredient'] as Map<String, dynamic>);
    final fridgeId = action['fridgeId'] as String;
    final itemData = {
      'id': ingredient.id,
      'name': ingredient.name,
      'category': ingredient.category,
      'imageURL': ingredient.imageURL,
      'quantity': ingredient.count,
    };
    await fridgeService.addGroceryItem(fridgeId, itemData);
  }

  /// Updates a grocery item based on the action details.
  Future<void> _updateGroceryItem(Map<String, dynamic> action) async {
    await fridgeService.updateGroceryItem(
      action['fridgeId'],
      action['itemId'],
      action['newCount'],
    );
  }

  /// Deletes a grocery item based on the action details.
  Future<void> _deleteGroceryItem(Map<String, dynamic> action) async {
    await fridgeService.deleteGroceryItem(
      action['fridgeId'],
      action['itemId'],
    );
  }

  /// Reorders grocery items based on the provided order.
  Future<void> _reorderGroceryItems(Map<String, dynamic> action) async {
    await fridgeService.saveGroceriesOrder(
      action['fridgeId'],
      List<String>.from(action['orderedIds']),
    );
  }
}