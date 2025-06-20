import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/providers/sync_actions/grocery_sync_actions.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/services/fridge_service.dart';

class MockFridgeService extends Mock implements FridgeService {}

void main() {
  late MockFridgeService mockService;
  late GrocerySyncActions actions;

  setUp(() {
    mockService = MockFridgeService();
    actions = GrocerySyncActions(mockService);

    final ingredient = Ingredient(
        id: 'i1', name: 'Egg', category: 'Dairy', imageURL: '', count: 1);
    when(mockService.addGroceryItem('f1', ingredient as Map<String, dynamic>))
        .thenAnswer((_) async => true);
    when(mockService.updateGroceryItem('f1', 'i1', 2))
        .thenAnswer((_) async => true);
    when(mockService.deleteGroceryItem('f1', 'i1'))
        .thenAnswer((_) async => true);
    when(mockService.saveGroceriesOrder('f1', ['i1', 'i2']))
        .thenAnswer((_) async {});
  });

  test('add calls addGroceryItem', () async {
    final ingredient = Ingredient(
        id: 'i1', name: 'Egg', category: 'Dairy', imageURL: '', count: 1);
    final action = {
      'action': 'add',
      'fridgeId': 'f1',
      'ingredient': ingredient.toJson(),
    };
    await actions.handleGroceryAction(action);
  });

  test('update calls updateGroceryItem', () async {
    final action = {
      'action': 'update',
      'fridgeId': 'f1',
      'itemId': 'i1',
      'newCount': 2,
    };
    await actions.handleGroceryAction(action);
    verify(mockService.updateGroceryItem('f1', 'i1', 2)).called(1);
  });

  test('delete calls deleteGroceryItem', () async {
    final action = {
      'action': 'delete',
      'fridgeId': 'f1',
      'itemId': 'i1',
    };
    await actions.handleGroceryAction(action);
    verify(mockService.deleteGroceryItem('f1', 'i1')).called(1);
  });

  test('reorder calls saveGroceriesOrder', () async {
    final action = {
      'action': 'reorder',
      'fridgeId': 'f1',
      'orderedIds': ['i1', 'i2'],
    };
    await actions.handleGroceryAction(action);
    verify(mockService.saveGroceriesOrder('f1', ['i1', 'i2'])).called(1);
  });
}
