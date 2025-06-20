import 'package:mockito/mockito.dart';
import 'package:snapchef/services/fridge_service.dart';

class MockFridgeService extends Mock implements FridgeService {
  @override
  Future<bool> addFridgeItem(String id, Map<String, dynamic> item) async {
    return true;
  }

  @override
  Future<bool> updateFridgeItem(String id, String name, int quantity) async {
    return true;
  }

  @override
  Future<bool> deleteFridgeItem(String id, String name) async {
    return true;
  }

  @override
  Future<void> saveFridgeOrder(String id, List<String> order) async {
    return;
  }
}