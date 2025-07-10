import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/models/shared_recipe.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/repositories/shared_recipe_repository.dart';
import 'package:snapchef/services/sync_service.dart';

@GenerateNiceMocks([
  MockSpec<ConnectivityProvider>(),
  MockSpec<SharedRecipeRepository>(),
  MockSpec<SyncProvider>(),
  MockSpec<SyncManager>(),
])
import 'shared_recipe_viewmodel_test.mocks.dart';

Recipe get dummyRecipe => Recipe(
      id: 'r1',
      title: 'Test Recipe',
      description: 'desc',
      mealType: 'Dinner',
      cuisineType: 'Italian',
      difficulty: 'Easy',
      prepTime: 10,
      cookingTime: 20,
      ingredients: [],
      instructions: [],
      imageURL: '',
      rating: null,
      source: RecipeSource.ai,
    );

SharedRecipe get testSharedRecipe => SharedRecipe(
      id: 'sr1',
      recipe: dummyRecipe,
      fromUser: 'userA',
      toUser: 'userB',
      sharedAt: DateTime.now(),
      status: 'pending',
    );

void main() {
  late SharedRecipeViewModel vm;
  late MockConnectivityProvider mockConnectivity;
  late MockSharedRecipeRepository mockRepo;
  late MockSyncProvider mockSyncProvider;
  late MockSyncManager mockSyncManager;

  setUp(() {
    GetIt.I.reset();
    mockConnectivity = MockConnectivityProvider();
    mockRepo = MockSharedRecipeRepository();
    mockSyncProvider = MockSyncProvider();
    mockSyncManager = MockSyncManager();

    GetIt.I.registerSingleton<ConnectivityProvider>(mockConnectivity);
    GetIt.I.registerSingleton<SharedRecipeRepository>(mockRepo);
    GetIt.I.registerSingleton<SyncProvider>(mockSyncProvider);
    GetIt.I.registerSingleton<SyncManager>(mockSyncManager);

    // Mocks for syncProvider and syncManager
    when(mockSyncProvider.syncPendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.initSync(any)).thenReturn(null);
    when(mockSyncProvider.loadPendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.getPendingActions(any)).thenAnswer((_) async => []);
    when(mockSyncProvider.savePendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.disposeSync()).thenReturn(null);
    when(mockSyncProvider.addPendingAction(any, any)).thenReturn(null);
    when(mockSyncManager.register(any)).thenReturn(null);
    when(mockSyncManager.unregister(any)).thenReturn(null);

    vm = SharedRecipeViewModel();
  });

  test('fetchSharedRecipes loads from local DB when offline', () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockRepo.fetchSharedRecipesLocal('userB')).thenAnswer((_) async => [
          testSharedRecipe,
        ]);

    await vm.fetchSharedRecipes('cb1', 'userB');

    expect(vm.sharedWithMeRecipes, isNotNull);
    expect(vm.sharedByMeRecipes, isNotNull);
    expect(vm.sharedWithMeRecipes!.any((r) => r.toUser == 'userB'), isTrue);
    expect(vm.sharedByMeRecipes!.any((r) => r.fromUser == 'userB'), isFalse);
    expect(vm.isLoading, isTrue); // isLoading is set true but not set false in offline branch
  });

  test('fetchSharedRecipes loads from remote when online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockRepo.fetchSharedRecipesRemote('cb1')).thenAnswer((_) async => {
          'sharedWithMe': [testSharedRecipe],
          'sharedByMe': [],
        });
    when(mockRepo.storeSharedRecipesLocal(any)).thenAnswer((_) async {});

    await vm.fetchSharedRecipes('cb1', 'userB');

    expect(vm.sharedWithMeRecipes, isNotNull);
    expect(vm.sharedWithMeRecipes!.length, 1);
    expect(vm.sharedWithMeRecipes!.first.id, testSharedRecipe.id);
    expect(vm.sharedByMeRecipes, isNotNull);
    expect(vm.sharedByMeRecipes!.isEmpty, isTrue);
    expect(vm.isLoading, isFalse);
  });

  test('fetchSharedRecipes sets empty lists when local DB returns empty',
      () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockRepo.fetchSharedRecipesLocal('userB')).thenAnswer((_) async => []);
    await vm.fetchSharedRecipes('cb1', 'userB');
    expect(vm.sharedWithMeRecipes, isEmpty);
    expect(vm.sharedByMeRecipes, isEmpty);
  });

  test('removeSharedRecipe removes locally and queues for sync when offline',
      () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockRepo.removeSharedRecipeLocal('sr1')).thenAnswer((_) async {});
    when(mockSyncProvider.savePendingActions()).thenAnswer((_) async {});
    when(mockSyncProvider.addPendingAction(any, any)).thenReturn(null);

    vm.sharedWithMeRecipes = [testSharedRecipe];
    vm.sharedByMeRecipes = [];

    await vm.removeSharedRecipe('cb1', 'sr1', isSharedByMe: false);

    expect(vm.sharedWithMeRecipes!.any((r) => r.id == 'sr1'), isFalse);
    verify(mockRepo.removeSharedRecipeLocal('sr1')).called(1);
    verify(mockSyncProvider.addPendingAction('cookbook', any)).called(1);
    verify(mockSyncProvider.savePendingActions()).called(1);
  });

  test('removeSharedRecipe removes remotely and locally when online', () async {
    when(mockConnectivity.isOffline).thenReturn(false);
    when(mockRepo.removeSharedRecipeRemote('cb1', 'sr1'))
        .thenAnswer((_) async {});
    when(mockRepo.removeSharedRecipeLocal('sr1')).thenAnswer((_) async {});

    vm.sharedWithMeRecipes = [testSharedRecipe];
    vm.sharedByMeRecipes = [];

    await vm.removeSharedRecipe('cb1', 'sr1', isSharedByMe: false);

    expect(vm.sharedWithMeRecipes!.any((r) => r.id == 'sr1'), isFalse);
    verify(mockRepo.removeSharedRecipeRemote('cb1', 'sr1')).called(1);
    verify(mockRepo.removeSharedRecipeLocal('sr1')).called(1);
  });

  test('removeSharedRecipe throws if local remove fails when offline',
      () async {
    when(mockConnectivity.isOffline).thenReturn(true);
    when(mockRepo.removeSharedRecipeLocal('sr1')).thenThrow(Exception('fail'));
    expect(
      () => vm.removeSharedRecipe('cb1', 'sr1', isSharedByMe: false),
      throwsException,
    );
  });

  test('clear resets lists and flags', () {
    vm.sharedWithMeRecipes = [testSharedRecipe];
    vm.sharedByMeRecipes = [testSharedRecipe];
    vm.setLoading(true);
    vm.setLoggingOut(true);
    vm.clear();
    expect(vm.sharedWithMeRecipes, isEmpty);
    expect(vm.sharedByMeRecipes, isEmpty);
    expect(vm.isLoading, isFalse);
    expect(vm.isLoggingOut, isFalse);
  });

  test('dispose calls syncProvider.disposeSync and syncManager.unregister', () {
    vm.dispose();
    verify(mockSyncProvider.disposeSync()).called(1);
    verify(mockSyncManager.unregister(mockSyncProvider.syncPendingActions))
        .called(1);
  });

  test('groupedSharedByMeRecipes groups recipes by recipe id', () {
    final recipe2 = Recipe(
      id: 'r2',
      title: 'Recipe 2',
      description: 'desc2',
      mealType: 'Lunch',
      cuisineType: 'French',
      difficulty: 'Medium',
      prepTime: 5,
      cookingTime: 15,
      ingredients: [],
      instructions: [],
      imageURL: '',
      rating: null,
      source: RecipeSource.ai,
    );
    final shared1 = SharedRecipe(
      id: 'sr1',
      recipe: dummyRecipe,
      fromUser: 'userA',
      toUser: 'userB',
      sharedAt: DateTime.now(),
      status: 'pending',
    );
    final shared2 = SharedRecipe(
      id: 'sr2',
      recipe: dummyRecipe,
      fromUser: 'userA',
      toUser: 'userC',
      sharedAt: DateTime.now(),
      status: 'pending',
    );
    final shared3 = SharedRecipe(
      id: 'sr3',
      recipe: recipe2,
      fromUser: 'userA',
      toUser: 'userD',
      sharedAt: DateTime.now(),
      status: 'pending',
    );
    vm.sharedByMeRecipes = [shared1, shared2, shared3];
    final grouped = vm.groupedSharedByMeRecipes;
    expect(grouped.length, 2);
    final group1 = grouped.firstWhere((g) => g.recipe.id == 'r1');
    expect(group1.sharedWithUserIds, containsAll(['userB', 'userC']));
    final group2 = grouped.firstWhere((g) => g.recipe.id == 'r2');
    expect(group2.sharedWithUserIds, contains('userD'));
  });
}