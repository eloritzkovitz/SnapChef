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

    // --- Fetching Recipes ---
    test('fetchCookbookRecipes loads remote and local, merges, and stores', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      fakeRecipes.add(testRecipe);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');

      expect(vm.recipes.length, 1);
      verify(mockRepo.fetchCookbookRecipesRemote('cb1')).called(1);
      verify(mockRepo.storeCookbookRecipesLocal('cb1', any)).called(1);
    });

    test('fetchCookbookRecipes loads from local if offline', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      fakeRecipes.add(testRecipe);

      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');

      expect(vm.recipes.length, 1);
      verify(mockRepo.fetchCookbookRecipesLocal('cb1')).called(1);
    });

    test('fetchCookbookRecipes falls back to local on remote error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockRepo.fetchCookbookRecipesRemote(any))
          .thenThrow(Exception('fail'));
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(vm.recipes.length, 1);
      verify(mockRepo.fetchCookbookRecipesLocal('cb1')).called(1);
    });

    // --- Adding/Updating/Deleting Recipes ---
    test('addRecipeToCookbook adds recipe and stores locally when offline', () async {
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
      verify(mockRepo.addRecipeToCookbookRemote('cb1', any, raw: null)).called(1);
    });

    test('addRecipeToCookbook returns false on error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockRepo.addRecipeToCookbookRemote(any, any, raw: anyNamed('raw')))
          .thenThrow(Exception('fail'));
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
      expect(result, isFalse);
    });

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

    test('updateRecipe returns false on error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockRepo.updateRecipeRemote(any, any, any))
          .thenThrow(Exception('fail'));
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
      expect(result, isFalse);
    });

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

    test('deleteRecipe returns false on error', () async {
      when(mockConnectivity.isOffline).thenReturn(false);
      when(mockRepo.deleteRecipeRemote(any, any)).thenThrow(Exception('fail'));
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final result = await vm.deleteRecipe('cb1', '1');
      expect(result, isFalse);
    });

    // --- Favorites & Reordering ---
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

    test('toggleRecipeFavoriteStatus returns false if recipe not found', () async {
      when(mockConnectivity.isOffline).thenReturn(true);
      final vm = CookbookViewModel();
      final result = await vm.toggleRecipeFavoriteStatus('cb1', 'notfound');
      expect(result, isFalse);
    });

    test('reorderRecipe reorders recipes and stores locally when offline', () async {
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

    test('reorderRecipe does nothing if index out of range', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      await vm.reorderRecipe(5, 1, 'cb1');
      await vm.reorderRecipe(0, 5, 'cb1');
    });

    // --- Filtering, Sorting, and Searching ---
    test('searchRecipes returns matching recipes', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final results = vm.searchRecipes('test');
      expect(results.length, 1);
      expect(results.first.title, 'Test Recipe');
    });

    test('searchRecipes returns empty list for no match', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      final results = vm.searchRecipes('notfound');
      expect(results, isEmpty);
    });

    test('applyFiltersAndSorting does not throw', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(() => vm.applyFiltersAndSorting(), returnsNormally);
    });

    test('applyFiltersAndSorting applies all filters and sorting', () async {
      fakeRecipes.add(testRecipe.copyWith(
        id: '2',
        title: 'Another',
        mealType: 'Lunch',
        cuisineType: 'French',
        difficulty: 'Medium',
        prepTime: 15,
        cookingTime: 25,
        rating: 3.0,
        source: RecipeSource.ai,
      ));
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      vm.selectedCategory = 'Lunch';
      vm.selectedCuisine = 'French';
      vm.selectedDifficulty = 'Medium';
      vm.prepTimeRange = const RangeValues(10, 20);
      vm.cookingTimeRange = const RangeValues(20, 30);
      vm.ratingRange = const RangeValues(2, 4);
      vm.selectedSource = 'ai';
      vm.filter = 'Another';
      vm.selectedSortOption = 'Name';
      vm.applyFiltersAndSorting();
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.title, 'Another');
    });

    test('filterByCategory and filterBySearch work as expected', () {
      final vm = CookbookViewModel();
      fakeRecipes.add(testRecipe);
      vm.applyFiltersAndSorting();
      expect(vm.filterByCategory(testRecipe, 'Dinner'), isTrue);
      expect(vm.filterByCategory(testRecipe, 'Lunch'), isFalse);
      expect(vm.filterBySearch(testRecipe, 'test'), isTrue);
      expect(vm.filterBySearch(testRecipe, 'notfound'), isFalse);
    });

    test('sortItems works for all options', () {
      final vm = CookbookViewModel();
      final r1 = testRecipe;
      final r2 = r1.copyWith(
          id: '2', title: 'A', rating: 2, prepTime: 5, cookingTime: 5);
      expect(vm.sortItems(r1, r2, 'Name'), greaterThan(0));
      expect(vm.sortItems(r2, r1, 'Name'), lessThan(0));
      expect(vm.sortItems(r1, r2, 'Rating'), lessThan(0));
      expect(vm.sortItems(r1, r2, 'PrepTime'), greaterThan(0));
      expect(vm.sortItems(r1, r2, 'CookingTime'), greaterThan(0));
      expect(vm.sortItems(r1, r2, null), 0);
    });

    // --- Getters & State ---
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

    test('min/max getters return 0 for empty recipes', () {
      final vm = CookbookViewModel();
      expect(vm.minPrepTime, 0);
      expect(vm.maxPrepTime, 0);
      expect(vm.minCookingTime, 0);
      expect(vm.maxCookingTime, 0);
      expect(vm.minRating, 0);
      expect(vm.maxRating, 0);
    });

    test('min/max getters return correct values for one recipe', () async {
      fakeRecipes.add(testRecipe);
      final vm = CookbookViewModel();
      await vm.fetchCookbookRecipes('cb1');
      expect(vm.minPrepTime, testRecipe.prepTime);
      expect(vm.maxPrepTime, testRecipe.prepTime);
      expect(vm.minCookingTime, testRecipe.cookingTime);
      expect(vm.maxCookingTime, testRecipe.cookingTime);
      expect(vm.minRating, testRecipe.rating);
      expect(vm.maxRating, testRecipe.rating);
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

    // --- Image, Sharing, and Save Order ---
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

    test('regenerateRecipeImage returns false if recipe not found', () async {
      when(mockRepo.regenerateRecipeImage(any, any, any))
          .thenAnswer((_) async => 'new_image_url');
      final vm = CookbookViewModel();
      final result = await vm.regenerateRecipeImage(
        cookbookId: 'cb1',
        recipeId: 'notfound',
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

    // --- Clear, Dispose, and Edge Cases ---
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
      expect(vm.filteredItems, isEmpty);
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