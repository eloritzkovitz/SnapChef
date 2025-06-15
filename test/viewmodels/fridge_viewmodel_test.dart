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
        fakeIngredients = List<Ingredient>.from(invocation.positionalArguments[1]);
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
      when(mockFridgeRepo.deleteFridgeItemLocal(any)).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        fakeIngredients.removeWhere((i) => i.id == id);
      });
      when(mockFridgeRepo.deleteFridgeItemRemote(any, any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[1] as String;
        fakeIngredients.removeWhere((i) => i.id == id);
        return true;
      });
      when(mockFridgeRepo.saveFridgeOrder(any, any)).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        fakeIngredients.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
      });

      // Groceries
      when(mockFridgeRepo.fetchGroceriesRemote(any))
          .thenAnswer((_) async => List<Ingredient>.from(fakeGroceries));
      when(mockFridgeRepo.fetchGroceriesLocal(any))
          .thenAnswer((_) async => List<Ingredient>.from(fakeGroceries));
      when(mockFridgeRepo.storeGroceriesLocal(any, any))
          .thenAnswer((invocation) async {
        fakeGroceries = List<Ingredient>.from(invocation.positionalArguments[1]);
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
      when(mockFridgeRepo.deleteGroceryItemLocal(any)).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        fakeGroceries.removeWhere((i) => i.id == id);
      });
      when(mockFridgeRepo.deleteGroceryItemRemote(any, any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[1] as String;
        fakeGroceries.removeWhere((i) => i.id == id);
        return true;
      });
      when(mockFridgeRepo.saveGroceriesOrder(any, any)).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        fakeGroceries.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
      });
    });

    // Checks that remote and local fridge ingredients are loaded and merged when online
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

    // Checks that fridge ingredients are loaded from local storage when offline
    test('fetchFridgeIngredients loads from local if offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeIngredients.clear();
      fakeIngredients.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchFridgeIngredients('fridge1', mockIngredientVM);

      expect(vm.ingredients.length, 1);
      verify(mockFridgeRepo.fetchFridgeItemsLocal('fridge1')).called(1);
    });

    // Checks that adding a fridge item stores it locally when offline
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

    // Checks that adding a fridge item adds it remotely when online
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

    // Checks that updating a fridge item updates it locally when offline
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

    // Checks that deleting a fridge item removes it locally when offline
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

    // Checks that reordering fridge ingredients does not call saveFridgeOrder if not implemented
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

    // Checks that remote and local groceries are loaded and merged when online
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

    // Checks that groceries are loaded from local storage when offline
    test('fetchGroceries loads from local if offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeGroceries.clear();
      fakeGroceries.add(testIngredient);

      final vm = FridgeViewModel();
      await vm.fetchGroceries('fridge1', mockIngredientVM);

      expect(vm.groceries.length, 1);
      verify(mockFridgeRepo.fetchGroceriesLocal('fridge1')).called(1);
    });

    // Checks that adding a grocery stores it locally when offline
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

    // Checks that adding a grocery adds it remotely when online
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

    // Checks that updating a grocery updates it locally when offline
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

    // Checks that deleting a grocery removes it locally when offline
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

    // Checks that reordering groceries does not call saveGroceriesOrder if not implemented
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
  });
}