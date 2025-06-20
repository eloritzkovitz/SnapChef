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
  });
}
