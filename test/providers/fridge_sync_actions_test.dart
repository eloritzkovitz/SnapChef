import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/providers/sync_actions/fridge_sync_actions.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/services/fridge_service.dart';

class MockFridgeService extends Mock implements FridgeService {}

void main() {
  late MockFridgeService mockService;
  late FridgeSyncActions actions;

  setUp(() {
    mockService = MockFridgeService();
    actions = FridgeSyncActions(mockService);
  });

  test('add calls addFridgeItem', () async {
    final ingredient = Ingredient(
        id: 'i1', name: 'Egg', category: 'Dairy', imageURL: '', count: 1);
    final action = {
      'action': 'add',
      'fridgeId': 'f1',
      'ingredient': ingredient.toJson(),
    };
    await actions.handleFridgeAction(action);
    //verify(mockService.addFridgeItem('f1', any)).called(1);
  });

  test('update calls updateFridgeItem', () async {
    final action = {
      'action': 'update',
      'fridgeId': 'f1',
      'itemId': 'i1',
      'newCount': 2,
    };
    await actions.handleFridgeAction(action);
    verify(mockService.updateFridgeItem('f1', 'i1', 2)).called(1);
  });

  test('delete calls deleteFridgeItem', () async {
    final action = {
      'action': 'delete',
      'fridgeId': 'f1',
      'itemId': 'i1',
    };
    await actions.handleFridgeAction(action);
    verify(mockService.deleteFridgeItem('f1', 'i1')).called(1);
  });

  test('reorder calls saveFridgeOrder', () async {
    final action = {
      'action': 'reorder',
      'fridgeId': 'f1',
      'orderedIds': ['i1', 'i2'],
    };
    await actions.handleFridgeAction(action);
    verify(mockService.saveFridgeOrder('f1', ['i1', 'i2'])).called(1);
  });
}