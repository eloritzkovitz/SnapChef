import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/repositories/cookbook_repository.dart';
import 'package:snapchef/database/app_database.dart' as db;
import 'package:snapchef/providers/sync_provider.dart';

@GenerateNiceMocks([
  MockSpec<db.AppDatabase>(),
  MockSpec<ConnectivityProvider>(),
  MockSpec<CookbookRepository>(),
  MockSpec<SyncProvider>(),
  MockSpec<SyncManager>(),
])
import 'cookbook_viewmodel_test.mocks.dart';

Recipe get testRecipe => Recipe(
      id: '1',
      title: 'Test Recipe',
      description: 'desc',
      mealType: 'Dinner',
      cuisineType: 'Italian',
      difficulty: 'Easy',
      prepTime: 10,
      cookingTime: 20,
      ingredients: [
        Ingredient(
          id: 'ing1',
          name: 'Salt',
          category: 'Spices',
          imageURL: 'assets/images/placeholder_image.png',
          count: 1,
        )
      ],
      instructions: ['Mix', 'Cook'],
      imageURL: '',
      rating: 4.5,
      isFavorite: false,
      source: RecipeSource.user,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppDatabase mockDb;
  late MockConnectivityProvider mockConnectivity;
  late MockCookbookRepository mockRepo;
  late MockSyncProvider mockSyncProvider;
  late MockSyncManager mockSyncManager;

  setUp(() {
    GetIt.I.reset();
    mockDb = MockAppDatabase();
    mockConnectivity = MockConnectivityProvider();
    mockRepo = MockCookbookRepository();
    mockSyncProvider = MockSyncProvider();
    mockSyncManager = MockSyncManager();

    GetIt.I.registerSingleton<db.AppDatabase>(mockDb);
    GetIt.I.registerSingleton<ConnectivityProvider>(mockConnectivity);
    GetIt.I.registerSingleton<CookbookRepository>(mockRepo);
    GetIt.I.registerSingleton<SyncProvider>(mockSyncProvider);
    GetIt.I.registerSingleton<SyncManager>(mockSyncManager);

    when(mockSyncProvider.syncPendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.loadPendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.savePendingActions()).thenAnswer((_) async {});
  });

  group('CookbookViewModel', () {
    late List<Recipe> fakeRecipes;

    setUp(() {
      fakeRecipes = [];
      when(mockRepo.fetchCookbookRecipesRemote(any))
          .thenAnswer((_) async => List<Recipe>.from(fakeRecipes));
      when(mockRepo.fetchCookbookRecipesLocal(any))
          .thenAnswer((_) async => List<Recipe>.from(fakeRecipes));
      when(mockRepo.storeCookbookRecipesLocal(any, any))
          .thenAnswer((invocation) async {
        fakeRecipes = List<Recipe>.from(invocation.positionalArguments[1]);
      });
      when(mockRepo.addRecipeToCookbookLocal(any, any))
          .thenAnswer((invocation) async {
        fakeRecipes.add(invocation.positionalArguments[1] as Recipe);
      });
      when(mockRepo.addRecipeToCookbookRemote(any, any, raw: anyNamed('raw')))
          .thenAnswer((invocation) async {
        fakeRecipes.add(invocation.positionalArguments[1] as Recipe);
        return true;
      });
      when(mockRepo.updateRecipeLocal(any, any)).thenAnswer((invocation) async {
        final updated = invocation.positionalArguments[1] as Recipe;
        final index = fakeRecipes.indexWhere((r) => r.id == updated.id);
        if (index != -1) {
          fakeRecipes[index] = updated;
        }
      });
      when(mockRepo.deleteRecipeLocal(any)).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        fakeRecipes.removeWhere((r) => r.id == id);
      });
      when(mockRepo.toggleRecipeFavoriteStatusLocal(any, any))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        final value = invocation.positionalArguments[1] as bool;
        final index = fakeRecipes.indexWhere((r) => r.id == id);
        if (index != -1) {
          fakeRecipes[index] = fakeRecipes[index].copyWith(isFavorite: value);
        }
      });
      when(mockRepo.saveRecipeOrderLocal(any)).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[0] as List<String>;
        fakeRecipes
            .sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
      });
    });

    // Test for fetchCookbookRecipes when online
    test('fetchCookbookRecipes loads remote and local, merges, and stores',
        () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      fakeRecipes.add(testRecipe);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');

      expect(vm.recipes.length, 1);
      verify(mockRepo.fetchCookbookRecipesRemote('cb1')).called(1);
      verify(mockRepo.storeCookbookRecipesLocal('cb1', any)).called(1);
    });

    // Test for fetchCookbookRecipes when offline
    test('fetchCookbookRecipes loads from local if offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeRecipes.add(testRecipe);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');

      expect(vm.recipes.length, 1);
      verify(mockRepo.fetchCookbookRecipesLocal('cb1')).called(1);
    });

    // Test for addRecipeToCookbook when offline
    test('addRecipeToCookbook adds recipe and stores locally when offline',
        () async {
      when(mockConnectivity.isOffline).thenReturn(true);

      final vm = CookbookViewModel();
      final result = await vm.addRecipeToCookbook(
        cookbookId: 'cb1',
        title: 'Test',
        description: 'desc',
        mealType: 'Dinner',
        cuisineType: 'Italian',
        difficulty: 'Easy',
        prepTime: 10,
        cookingTime: 20,
        ingredients: [
          Ingredient(
            id: 'ing1',
            name: 'Salt',
            category: 'Spices',
            imageURL: 'assets/images/placeholder_image.png',
            count: 1,
          )
        ],
        instructions: ['Mix', 'Cook'],
        source: RecipeSource.user,
      );
      expect(result, isTrue);
      expect(fakeRecipes.length, 1);
      verify(mockRepo.addRecipeToCookbookLocal('cb1', any)).called(1);
    });

    // Test for addRecipeToCookbook when online
    test('addRecipeToCookbook adds recipe remotely when online', () async {
      when(mockConnectivity.isOffline).thenReturn(false);

      final vm = CookbookViewModel();
      final result = await vm.addRecipeToCookbook(
        cookbookId: 'cb1',
        title: 'Test',
        description: 'desc',
        mealType: 'Dinner',
        cuisineType: 'Italian',
        difficulty: 'Easy',
        prepTime: 10,
        cookingTime: 20,
        ingredients: [
          Ingredient(
            id: 'ing1',
            name: 'Salt',
            category: 'Spices',
            imageURL: 'assets/images/placeholder_image.png',
            count: 1,
          )
        ],
        instructions: ['Mix', 'Cook'],
        source: RecipeSource.user,
      );
      expect(result, isTrue);
      expect(fakeRecipes.length, 1);
      verify(mockRepo.addRecipeToCookbookRemote('cb1', any, raw: null))
          .called(1);
    });

    // Test for updateRecipe
    test('updateRecipe updates recipe locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);

      fakeRecipes.add(testRecipe);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final result = await vm.updateRecipe(
        cookbookId: 'cb1',
        recipeId: '1',
        title: 'Updated',
        description: 'desc',
        mealType: 'Dinner',
        cuisineType: 'Italian',
        difficulty: 'Easy',
        prepTime: 10,
        cookingTime: 20,
        ingredients: [
          Ingredient(
            id: 'ing1',
            name: 'Salt',
            category: 'Spices',
            imageURL: 'assets/images/placeholder_image.png',
            count: 1,
          )
        ],
        instructions: ['Mix', 'Cook'],
        imageURL: '',
        rating: 5.0,
      );
      await vm.fetchCookbookRecipes('cb1');
      expect(result, isTrue);
      expect(vm.recipes.first.title, 'Updated');
      verify(mockRepo.updateRecipeLocal('cb1', any)).called(1);
    });

    // Test for deleteRecipe
    test('deleteRecipe removes recipe locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);

      fakeRecipes.add(testRecipe);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final result = await vm.deleteRecipe('cb1', '1');
      await vm.fetchCookbookRecipes('cb1');
      expect(result, isTrue);
      expect(vm.recipes.length, 0);
      verify(mockRepo.deleteRecipeLocal('1')).called(1);
    });

    // Test for toggleRecipeFavoriteStatus
    test('toggleRecipeFavoriteStatus toggles locally when offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);

      fakeRecipes.add(testRecipe);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final result = await vm.toggleRecipeFavoriteStatus('cb1', '1');
      await vm.fetchCookbookRecipes('cb1');
      expect(result, isTrue);
      expect(vm.recipes.first.isFavorite, isTrue);
      verify(mockRepo.toggleRecipeFavoriteStatusLocal('1', true)).called(1);
    });

    // Test for reorderRecipe
    test('reorderRecipe reorders recipes and stores locally when offline',
        () async {
      when(mockConnectivity.isOffline).thenReturn(true);

      final r1 = testRecipe;
      final r2 = r1.copyWith(id: '2', title: 'Second');
      fakeRecipes.addAll([r1, r2]);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      vm.applyFiltersAndSorting();

      await vm.reorderRecipe(0, 1, 'cb1');

      final verification = verify(mockRepo.saveRecipeOrderLocal(captureAny));
      final calledArg = verification.captured.single as List<String>;
      expect(calledArg, ['1', '2']);
    });

    // Test for searchRecipes
    test('searchRecipes returns matching recipes', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final results = vm.searchRecipes('test');
      expect(results.length, 1);
      expect(results.first.title, 'Test Recipe');
    });

    test('getCategories returns expected categories', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(vm.getCategories(), contains('Dinner'));
      expect(vm.getCategories().length, 1);
    });

    test('getCuisines returns expected cuisines', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(vm.getCuisines(), contains('Italian'));
      expect(vm.getCuisines().length, 1);
    });

    test('getDifficulties returns expected difficulties', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(vm.getDifficulties(), contains('Easy'));
      expect(vm.getDifficulties().length, 1);
    });

    test('min/max prep/cooking time and rating are correct', () {
      final vm = CookbookViewModel();
      expect(vm.minPrepTime, isA<int>());
      expect(vm.maxPrepTime, isA<int>());
      expect(vm.minCookingTime, isA<int>());
      expect(vm.maxCookingTime, isA<int>());
      expect(vm.minRating, isA<double>());
      expect(vm.maxRating, isA<double>());
    });

    test('clearFilters resets filters', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      vm.selectedCategory = 'Vegetable';
      vm.selectedSortOption = 'A-Z';
      vm.selectedCuisine = 'Italian';
      vm.selectedDifficulty = 'Easy';
      vm.prepTimeRange = const RangeValues(5, 30);
      vm.cookingTimeRange = const RangeValues(10, 40);
      vm.ratingRange = const RangeValues(1, 5);
      vm.selectedSource = 'user';
      vm.filter = 'Test';
      vm.clearFilters();
      expect(vm.selectedCategory, null);
      expect(vm.selectedSortOption, null);
      expect(vm.selectedCuisine, null);
      expect(vm.selectedDifficulty, null);
      expect(vm.prepTimeRange, null);
      expect(vm.cookingTimeRange, null);
      expect(vm.ratingRange, null);
      expect(vm.selectedSource, null);
      expect(vm.filter, '');
    });

    test('applyFiltersAndSorting does not throw', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(() => vm.applyFiltersAndSorting(), returnsNormally);
    });

    test('fields can be set and read', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      vm.selectedCategory = 'Vegetable';
      vm.selectedSortOption = 'A-Z';
      vm.selectedCuisine = 'Italian';
      vm.selectedDifficulty = 'Easy';
      vm.prepTimeRange = const RangeValues(5, 30);
      vm.cookingTimeRange = const RangeValues(10, 40);
      vm.ratingRange = const RangeValues(1, 5);
      vm.selectedSource = 'user';
      vm.filter = 'Test';
      expect(vm.selectedCategory, 'Vegetable');
      expect(vm.selectedSortOption, 'A-Z');
      expect(vm.selectedCuisine, 'Italian');
      expect(vm.selectedDifficulty, 'Easy');
      expect(vm.prepTimeRange, const RangeValues(5, 30));
      expect(vm.cookingTimeRange, const RangeValues(10, 40));
      expect(vm.ratingRange, const RangeValues(1, 5));
      expect(vm.selectedSource, 'user');
      expect(vm.filter, 'Test');
    });    

    test('searchRecipes returns empty list for no match', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final results = vm.searchRecipes('notfound');
      expect(results, isEmpty);
    });

    test('recipes getter returns current recipes', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(vm.recipes.length, 1);
      expect(vm.recipes.first.title, 'Test Recipe');
    });

    test('filteredItems getter returns filtered recipes', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      vm.applyFiltersAndSorting();
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.title, 'Test Recipe');
    });

    test('isLoading is false by default', () {
      final vm = CookbookViewModel();
      expect(vm.isLoading, isFalse);
    });

    test('errorMessage is null by default', () {
      final vm = CookbookViewModel();
      expect(vm.errorMessage, isNull);
    });

    test('isLoggingOut is false by default', () {
      final vm = CookbookViewModel();
      expect(vm.isLoggingOut, isFalse);
    });

    test('setLoading updates isLoading', () {
      final vm = CookbookViewModel();
      vm.setLoading(true);
      expect(vm.isLoading, isTrue);
      vm.setLoading(false);
      expect(vm.isLoading, isFalse);
    });

    test('setLoggingOut updates isLoggingOut', () {
      final vm = CookbookViewModel();
      vm.setLoggingOut(true);
      expect(vm.isLoggingOut, isTrue);
      vm.setLoggingOut(false);
      expect(vm.isLoggingOut, isFalse);
    });

    test('regenerateRecipeImage updates imageURL and returns true', () async {
      fakeRecipes.add(testRecipe);
      when(mockRepo.regenerateRecipeImage(any, any, any))
          .thenAnswer((_) async => 'new_image_url');
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final result = await vm.regenerateRecipeImage(
        cookbookId: 'cb1',
        recipeId: '1',
        payload: {},
      );
      expect(result, isTrue);
      expect(vm.recipes.first.imageURL, 'new_image_url');
    });

    test('regenerateRecipeImage returns false on error', () async {
      fakeRecipes.add(testRecipe);
      when(mockRepo.regenerateRecipeImage(any, any, any))
          .thenThrow(Exception('fail'));
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final result = await vm.regenerateRecipeImage(
        cookbookId: 'cb1',
        recipeId: '1',
        payload: {},
      );
      expect(result, isFalse);
    });

    test('saveRecipeOrder calls repository', () async {
      fakeRecipes.add(testRecipe);
      when(mockRepo.saveRecipeOrderRemote(any, any))
          .thenAnswer((_) async => {});
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      await vm.saveRecipeOrder('cb1');
      verify(mockRepo.saveRecipeOrderRemote('cb1', any)).called(1);
    });

    test('saveRecipeOrder handles error gracefully', () async {
      fakeRecipes.add(testRecipe);
      when(mockRepo.saveRecipeOrderRemote(any, any))
          .thenThrow(Exception('fail'));
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      await vm.saveRecipeOrder('cb1');
      // No throw expected
    });

    test('shareRecipeWithFriend calls repository', () async {
      when(mockRepo.shareRecipeWithFriend(
        cookbookId: anyNamed('cookbookId'),
        recipeId: anyNamed('recipeId'),
        friendId: anyNamed('friendId'),
      )).thenAnswer((_) async {});
      final vm = CookbookViewModel();
      await vm.shareRecipeWithFriend(
        cookbookId: 'cb1',
        recipeId: '1',
        friendId: 'friend1',
      );
      verify(mockRepo.shareRecipeWithFriend(
        cookbookId: 'cb1',
        recipeId: '1',
        friendId: 'friend1',
      )).called(1);
    });

    test('clear resets all fields and recipes', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      vm.selectedCategory = 'Vegetable';
      vm.selectedSortOption = 'A-Z';
      vm.selectedCuisine = 'Italian';
      vm.selectedDifficulty = 'Easy';
      vm.prepTimeRange = const RangeValues(5, 30);
      vm.cookingTimeRange = const RangeValues(10, 40);
      vm.ratingRange = const RangeValues(1, 5);
      vm.selectedSource = 'user';
      vm.filter = 'Test';
      vm.clear();
      expect(vm.recipes, isEmpty);
      expect(vm.selectedCategory, null);
      expect(vm.selectedSortOption, null);
      expect(vm.selectedCuisine, null);
      expect(vm.selectedDifficulty, null);
      expect(vm.prepTimeRange, null);
      expect(vm.cookingTimeRange, null);
      expect(vm.ratingRange, null);
      expect(vm.selectedSource, null);
      expect(vm.filter, '');
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
      final vm = CookbookViewModel();
      vm.dispose();
      expect(disposeSyncCalled, isTrue);
      expect(unregisterCalled, isTrue);
    });
  });
}
