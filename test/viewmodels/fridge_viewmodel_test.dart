import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/repositories/fridge_repository.dart';
import 'package:snapchef/services/fridge_service.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';

@GenerateNiceMocks([
  MockSpec<ConnectivityProvider>(),
  MockSpec<SyncProvider>(),
  MockSpec<SyncManager>(),
  MockSpec<FridgeRepository>(),
  MockSpec<FridgeService>(),
  MockSpec<IngredientViewModel>(),
])
import 'fridge_viewmodel_test.mocks.dart';

Ingredient get testIngredient => Ingredient(
      id: 'ing1',
      name: 'Salt',
      category: 'Spices',
      imageURL: 'assets/images/placeholder_image.png',
      count: 1,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockConnectivityProvider mockConnectivity;
  late MockSyncProvider mockSyncProvider;
  late MockSyncManager mockSyncManager;
  late MockFridgeRepository mockFridgeRepo;
  late MockFridgeService mockFridgeService;
  late MockIngredientViewModel mockIngredientVM;

  setUp(() {
    GetIt.I.reset();
    mockConnectivity = MockConnectivityProvider();
    mockSyncProvider = MockSyncProvider();
    mockSyncManager = MockSyncManager();
    mockFridgeRepo = MockFridgeRepository();
    mockFridgeService = MockFridgeService();
    mockIngredientVM = MockIngredientViewModel();

    GetIt.I.registerSingleton<ConnectivityProvider>(mockConnectivity);
    GetIt.I.registerSingleton<SyncProvider>(mockSyncProvider);
    GetIt.I.registerSingleton<SyncManager>(mockSyncManager);
    GetIt.I.registerSingleton<FridgeRepository>(mockFridgeRepo);

    when(mockFridgeRepo.fridgeService).thenReturn(mockFridgeService);

    when(mockSyncProvider.syncPendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.loadPendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.savePendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.initSync(any)).thenReturn(null);
    when(mockSyncProvider.disposeSync()).thenReturn(null);
    when(mockSyncManager.register(any)).thenReturn(null);
    when(mockSyncManager.unregister(any)).thenReturn(null);
  });

  group('FridgeViewModel', () {
    late List<Ingredient> fakeIngredients;
    late List<Ingredient> fakeGroceries;

    setUp(() {
      fakeIngredients = [];
      fakeGroceries = [];

      when(mockFridgeRepo.fetchFridgeItemsRemote(any))
          .thenAnswer((_) async => List<Ingredient>.from(fakeIngredients));
      when(mockFridgeRepo.fetchFridgeItemsLocal(any))
          .thenAnswer((_) async => List<Ingredient>.from(fakeIngredients));
      when(mockFridgeRepo.storeFridgeItemsLocal(any, any))
          .thenAnswer((invocation) async {
        fakeIngredients =
            List<Ingredient>.from(invocation.positionalArguments[1]);
      });
      when(mockFridgeRepo.addOrUpdateFridgeItem(any, any))
          .thenAnswer((invocation) async {
        final ing = invocation.positionalArguments[1] as Ingredient;
        final idx = fakeIngredients.indexWhere((i) => i.id == ing.id);
        if (idx != -1) {
          fakeIngredients[idx] = ing;
        } else {
          fakeIngredients.add(ing);
        }
      });
      when(mockFridgeRepo.addFridgeItemRemote(any, any))
          .thenAnswer((invocation) async {
        final ing = invocation.positionalArguments[1] as Ingredient;
        fakeIngredients.add(ing);
        return true;
      });
      when(mockFridgeRepo.updateFridgeItemRemote(any, any, any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[1] as String;
        final newCount = invocation.positionalArguments[2] as int;
        final idx = fakeIngredients.indexWhere((i) => i.id == id);
        if (idx != -1) {
          fakeIngredients[idx] = fakeIngredients[idx].copyWith(count: newCount);
          return true;
        }
        return false;
      });
      when(mockFridgeRepo.deleteFridgeItemLocal(any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        fakeIngredients.removeWhere((i) => i.id == id);
      });
      when(mockFridgeRepo.deleteFridgeItemRemote(any, any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[1] as String;
        fakeIngredients.removeWhere((i) => i.id == id);
        return true;
      });
      when(mockFridgeRepo.saveFridgeOrder(any, any))
          .thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        fakeIngredients
            .sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
      });

      // Groceries
      when(mockFridgeRepo.fetchGroceriesRemote(any))
          .thenAnswer((_) async => List<Ingredient>.from(fakeGroceries));
      when(mockFridgeRepo.fetchGroceriesLocal(any))
          .thenAnswer((_) async => List<Ingredient>.from(fakeGroceries));
      when(mockFridgeRepo.storeGroceriesLocal(any, any))
          .thenAnswer((invocation) async {
        fakeGroceries =
            List<Ingredient>.from(invocation.positionalArguments[1]);
      });
      when(mockFridgeRepo.addOrUpdateGroceryItem(any, any))
          .thenAnswer((invocation) async {
        final ing = invocation.positionalArguments[1] as Ingredient;
        final idx = fakeGroceries.indexWhere((i) => i.id == ing.id);
        if (idx != -1) {
          fakeGroceries[idx] = ing;
        } else {
          fakeGroceries.add(ing);
        }
      });
      when(mockFridgeRepo.addGroceryItemRemote(any, any))
          .thenAnswer((invocation) async {
        final ing = invocation.positionalArguments[1] as Ingredient;
        fakeGroceries.add(ing);
        return true;
      });
      when(mockFridgeRepo.updateGroceryItemRemote(any, any, any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[1] as String;
        final newCount = invocation.positionalArguments[2] as int;
        final idx = fakeGroceries.indexWhere((i) => i.id == id);
        if (idx != -1) {
          fakeGroceries[idx] = fakeGroceries[idx].copyWith(count: newCount);
          return true;
        }
        return false;
      });
      when(mockFridgeRepo.deleteGroceryItemLocal(any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        fakeGroceries.removeWhere((i) => i.id == id);
      });
      when(mockFridgeRepo.deleteGroceryItemRemote(any, any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[1] as String;
        fakeGroceries.removeWhere((i) => i.id == id);
        return true;
      });
      when(mockFridgeRepo.saveGroceriesOrder(any, any))
          .thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        fakeGroceries
            .sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
      });
    });

    // --- Fetching Data ---
    test('fetchFridgeIngredients loads remote and local, merges, and stores', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      fakeIngredients.clear();
      fakeIngredients.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);

      expect(vm.ingredients.length, 1);
      verify(mockFridgeRepo.fetchFridgeItemsRemote('fridge1')).called(1);
      verify(mockFridgeRepo.storeFridgeItemsLocal('fridge1', any)).called(1);
    });

    test('fetchFridgeIngredients loads from local if offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeIngredients.clear();
      fakeIngredients.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);

      expect(vm.ingredients.length, 1);
      verify(mockFridgeRepo.fetchFridgeItemsLocal('fridge1')).called(1);
    });

    test('fetchGroceries loads remote and local, merges, and stores', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      fakeGroceries.clear();
      fakeGroceries.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);

      expect(vm.groceries.length, 1);
      verify(mockFridgeRepo.fetchGroceriesRemote('fridge1')).called(1);
      verify(mockFridgeRepo.storeGroceriesLocal('fridge1', any)).called(1);
    });

    test('fetchGroceries loads from local if offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeGroceries.clear();
      fakeGroceries.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);

      expect(vm.groceries.length, 1);
      verify(mockFridgeRepo.fetchGroceriesLocal('fridge1')).called(1);
    });

    test('fetchData calls both fetchFridgeIngredients and fetchGroceries', () async {
      final vm = FridgeViewModel();
      await vm.fetchData(
          fridgeId: 'fridge1', ingredientViewModel: mockIngredientVM);
      expect(vm.ingredients, isA<List<Ingredient>>());
      expect(vm.groceries, isA<List<Ingredient>>());
    });

    // --- Fridge Item Add/Update/Delete ---
    test('addFridgeItem adds ingredient and stores locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeIngredients.clear();

      final vm = FridgeViewModel();
      final result = await vm.addFridgeItem(
        'fridge1',
        'ing1',
        'Salt',
        'Spices',
        'assets/images/placeholder_image.png',
        1,
      );
      expect(result, isTrue);
      expect(fakeIngredients.where((i) => i.id == 'ing1').length, 1);
      verify(mockFridgeRepo.addOrUpdateFridgeItem('fridge1', any)).called(1);
    });

    test('addFridgeItem adds ingredient remotely when online', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      fakeIngredients.clear();

      final vm = FridgeViewModel();
      final result = await vm.addFridgeItem(
        'fridge1',
        'ing1',
        'Salt',
        'Spices',
        'assets/images/placeholder_image.png',
        1,
      );
      expect(result, isTrue);
      expect(fakeIngredients.any((i) => i.id == 'ing1'), isTrue);
      verify(mockFridgeRepo.addFridgeItemRemote('fridge1', any)).called(1);
    });

    test('addFridgeItem returns false on remote error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockFridgeRepo.addFridgeItemRemote(any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      final result = await vm.addFridgeItem(
        'fridge1',
        'ing1',
        'Salt',
        'Spices',
        'img',
        1,
      );
      expect(result, isFalse);
    });

    test('updateFridgeItem updates ingredient locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeIngredients.clear();
      fakeIngredients.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      final result = await vm.updateFridgeItem('fridge1', 'ing1', 5);
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      expect(result, isTrue);
      expect(vm.ingredients.first.count, 5);
      verify(mockFridgeRepo.addOrUpdateFridgeItem('fridge1', any)).called(1);
    });

    test('updateFridgeItem returns false on remote error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockFridgeRepo.updateFridgeItemRemote(any, any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      final result = await vm.updateFridgeItem('fridge1', 'notfound', 5);
      expect(result, isFalse);
    });

    test('updateFridgeItem returns false if item not found', () async {
      final vm = FridgeViewModel();
      final result = await vm.updateFridgeItem('fridge1', 'notfound', 5);
      expect(result, isFalse);
    });

    test('deleteFridgeItem removes ingredient locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeIngredients.clear();
      fakeIngredients.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      final result = await vm.deleteFridgeItem('fridge1', 'ing1');
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      expect(result, isTrue);
      expect(vm.ingredients.length, 0);
      verify(mockFridgeRepo.deleteFridgeItemLocal('ing1')).called(1);
    });

    test('deleteFridgeItem returns false on remote error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockFridgeRepo.deleteFridgeItemRemote(any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      final result = await vm.deleteFridgeItem('fridge1', 'notfound');
      expect(result, isFalse);
    });

    // --- Grocery Item Add/Update/Delete ---
    test('addGroceryItem adds grocery and stores locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeGroceries.clear();

      final vm = FridgeViewModel();
      final result = await vm.addGroceryItem(
        'fridge1',
        'ing1',
        'Salt',
        'Spices',
        'assets/images/placeholder_image.png',
        1,
      );
      expect(result, isTrue);
      expect(fakeGroceries.where((i) => i.id == 'ing1').length, 1);
      verify(mockFridgeRepo.addOrUpdateGroceryItem('fridge1', any)).called(1);
    });

    test('addGroceryItem adds grocery remotely when online', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      fakeGroceries.clear();

      final vm = FridgeViewModel();
      final result = await vm.addGroceryItem(
        'fridge1',
        'ing1',
        'Salt',
        'Spices',
        'assets/images/placeholder_image.png',
        1,
      );
      expect(result, isTrue);
      expect(fakeGroceries.any((i) => i.id == 'ing1'), isTrue);
      verify(mockFridgeRepo.addGroceryItemRemote('fridge1', any)).called(1);
    });

    test('addGroceryItem returns false on remote error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockFridgeRepo.addGroceryItemRemote(any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      final result = await vm.addGroceryItem(
        'fridge1',
        'ing1',
        'Salt',
        'Spices',
        'img',
        1,
      );
      expect(result, isFalse);
    });

    test('updateGroceryItem updates grocery locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeGroceries.clear();
      fakeGroceries.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      final result = await vm.updateGroceryItem('fridge1', 'ing1', 5);
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      expect(result, isTrue);
      expect(vm.groceries.first.count, 5);
      verify(mockFridgeRepo.addOrUpdateGroceryItem('fridge1', any)).called(1);
    });

    test('updateGroceryItem returns false on remote error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockFridgeRepo.updateGroceryItemRemote(any, any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      final result = await vm.updateGroceryItem('fridge1', 'notfound', 5);
      expect(result, isFalse);
    });

    test('updateGroceryItem returns false if item not found', () async {
      final vm = FridgeViewModel();
      final result = await vm.updateGroceryItem('fridge1', 'notfound', 5);
      expect(result, isFalse);
    });

    test('deleteGroceryItem removes grocery locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeGroceries.clear();
      fakeGroceries.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      final result = await vm.deleteGroceryItem('fridge1', 'ing1');
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      expect(result, isTrue);
      expect(vm.groceries.length, 0);
      verify(mockFridgeRepo.deleteGroceryItemLocal('ing1')).called(1);
    });

    test('deleteGroceryItem returns false on remote error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockFridgeRepo.deleteGroceryItemRemote(any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      final result = await vm.deleteGroceryItem('fridge1', 'notfound');
      expect(result, isFalse);
    });

    // --- Reordering ---
    test('reorderIngredient reorders ingredients and stores locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeIngredients.clear();

      final ing1 = testIngredient;
      final ing2 = ing1.copyWith(id: 'ing2', name: 'Pepper');
      fakeIngredients.addAll([ing1, ing2]);

      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);

      await vm.reorderIngredient(0, 1, 'fridge1');

      verifyNever(mockFridgeRepo.saveFridgeOrder(any, any));
    });

    test('reorderIngredient does nothing if index out of range', () async {
      fakeIngredients.add(testIngredient);
      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      // Should not throw
      await vm.reorderIngredient(5, 1, 'fridge1');
      await vm.reorderIngredient(0, 5, 'fridge1');
    });

    test('reorderGroceryItem reorders groceries and stores locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeGroceries.clear();

      final ing1 = testIngredient;
      final ing2 = ing1.copyWith(id: 'ing2', name: 'Pepper');
      fakeGroceries.addAll([ing1, ing2]);

      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);

      await vm.reorderGroceryItem(0, 1, 'fridge1');

      verifyNever(mockFridgeRepo.saveGroceriesOrder(any, any));
    });

    test('reorderGroceryItem does nothing if index out of range', () async {
      fakeGroceries.add(testIngredient);
      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      // Should not throw
      await vm.reorderGroceryItem(5, 1, 'fridge1');
      await vm.reorderGroceryItem(0, 5, 'fridge1');
    });

    // --- Utility/State ---
    test('clear resets all fields and lists', () async {
      fakeIngredients.add(testIngredient);
      fakeGroceries.add(testIngredient);
      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      vm.recognizedIngredients = ['something'];
      vm.clear();
      expect(vm.ingredients, isEmpty);
      expect(vm.groceries, isEmpty);
      expect(vm.recognizedIngredients, isEmpty);
    });

    test('clear sets loading to false', () async {
      final vm = FridgeViewModel();
      vm.setLoading(true);
      vm.clear();
      expect(vm.isLoading, isFalse);
    });

    test('dispose calls syncProvider.disposeSync and unregisters sync', () {
      var disposeSyncCalled = false;
      var unregisterCalled = false;
      when(mockSyncProvider.disposeSync()).thenAnswer((_) {
        disposeSyncCalled = true;
      });
      when(mockSyncManager.unregister(any)).thenAnswer((_) {
        unregisterCalled = true;
      });
      final vm = FridgeViewModel();
      vm.dispose();
      expect(disposeSyncCalled, isTrue);
      expect(unregisterCalled, isTrue);
    });

    // --- Image/Recognition ---
    test('recognizeIngredients handles error gracefully', () async {
      final vm = FridgeViewModel();
      await vm.recognizeIngredients(File('notfound.jpg'), 'endpoint');
      expect(vm.recognizedIngredients, isEmpty);
    });

    test('updateFridgeIngredientImageURLs updates URLs', () async {
      fakeIngredients
          .add(testIngredient.copyWith(id: 'ing2', imageURL: 'old.png'));
      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);

      // Mock IngredientViewModel with new imageURL
      when(mockIngredientVM.ingredients).thenReturn(
          [testIngredient.copyWith(id: 'ing2', imageURL: 'new.png')]);

      when(mockFridgeRepo.updateFridgeItemImageURL(any, any, any))
          .thenAnswer((_) async {});
      await vm.updateFridgeIngredientImageURLs(mockIngredientVM, 'fridge1');
      expect(vm.ingredients.first.imageURL, 'new.png');
    });

    test('updateFridgeIngredientImageURLs does nothing if URLs match', () async {
      fakeIngredients.add(testIngredient);
      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      when(mockIngredientVM.ingredients).thenReturn([testIngredient]);
      await vm.updateFridgeIngredientImageURLs(mockIngredientVM, 'fridge1');
      // No exception, no update needed
      expect(vm.ingredients.first.imageURL, testIngredient.imageURL);
    });

    // --- Edge Cases & Error Handling ---
    test('changeCount does nothing if newCount < 1', () async {
      fakeIngredients.add(testIngredient.copyWith(count: 1));
      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      // Should not throw or update
      vm.changeCount(filteredIndex: 0, fridgeId: 'fridge1', delta: -2);
      expect(vm.ingredients.first.count, 1);
    });

    test('changeCount updates count if newCount >= 1', () async {
      fakeIngredients.add(testIngredient.copyWith(count: 1));
      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      await vm.updateFridgeItem('fridge1', testIngredient.id, 2);
      vm.changeCount(filteredIndex: 0, fridgeId: 'fridge1', delta: 1);
      expect(vm.ingredients.first.count, 3);
    });

    test('addGroceryToFridge moves item and removes from groceries', () async {
      fakeGroceries.add(testIngredient);
      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      await vm.addGroceryToFridge('fridge1', testIngredient);
      expect(vm.groceries.where((g) => g.id == testIngredient.id), isEmpty);
      expect(vm.ingredients.where((i) => i.id == testIngredient.id).isNotEmpty,
          isTrue);
    });

    test('addGroceryToFridge increments count if already in fridge', () async {
      fakeIngredients.add(testIngredient.copyWith(count: 2));
      fakeGroceries.add(testIngredient.copyWith(count: 3));
      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);
      await vm.fetchGroceries('fridge1', mockIngredientVM);
      await vm.addGroceryToFridge('fridge1', testIngredient.copyWith(count: 3));
      expect(vm.ingredients.first.count, 5);
    });

    test('saveFridgeOrder handles error gracefully', () async {
      when(mockFridgeRepo.saveFridgeOrder(any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      await vm.saveFridgeOrder('fridge1');
      // Should not throw
    });

    test('saveGroceriesOrder handles error gracefully', () async {
      when(mockFridgeRepo.saveGroceriesOrder(any, any))
          .thenThrow(Exception('fail'));
      final vm = FridgeViewModel();
      await vm.saveGroceriesOrder('fridge1');
      // Should not throw
    });
  });
}