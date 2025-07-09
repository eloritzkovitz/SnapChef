import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/database/daos/ingredient_dao.dart';
import 'package:snapchef/database/app_database.dart' as db;

@GenerateNiceMocks([
  MockSpec<IngredientService>(),
  MockSpec<IngredientDao>(),
])
import 'ingredient_viewmodel_test.mocks.dart';

// Helper fake AppDatabase for GetIt
class FakeAppDatabase implements db.AppDatabase {
  @override
  final IngredientDao ingredientDao;
  FakeAppDatabase(this.ingredientDao);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

db.Ingredient get testIngredient => db.Ingredient(
      id: 'ing1',
      name: 'Salt',
      category: 'Spices',
      imageURL: 'assets/images/placeholder_image.png',      
    );

void main() {
  late IngredientViewModel vm;
  late MockIngredientService mockService;
  late MockIngredientDao mockDao;

  setUp(() {
    GetIt.I.reset();
    mockService = MockIngredientService();
    mockDao = MockIngredientDao();

    // Register mocks with GetIt for dependency lookup
    GetIt.I.registerSingleton<IngredientService>(mockService);
    GetIt.I.registerSingleton<db.AppDatabase>(FakeAppDatabase(mockDao));

    vm = IngredientViewModel();
  });

  test('fetchIngredients loads from backend and updates local DB if different',
      () async {
    // Backend returns one ingredient as JSON
    when(mockService.getAllIngredients()).thenAnswer((_) async => [
          testIngredient.toJson(),
        ]);
    // Local DB is empty
    when(mockDao.getAllIngredients())
        .thenAnswer((_) => Future.value(<db.Ingredient>[]));
    when(mockDao.insertIngredient(any)).thenAnswer((_) async => 1);
    when(mockDao.deleteIngredient(any)).thenAnswer((_) async => 1);

    await vm.fetchIngredients();

    expect(vm.ingredients.length, 1);
    expect(vm.ingredients.first.id, testIngredient.id);
    expect(vm.ingredientMap![testIngredient.name.trim().toLowerCase()]?.id,
        testIngredient.id);    

    verify(mockDao.insertIngredient(any)).called(1);
    verifyNever(mockDao.deleteIngredient(any));
  });

  test('fetchIngredients loads from local DB if backend fails', () async {
    // Backend throws
    when(mockService.getAllIngredients()).thenThrow(Exception('fail'));
    // Local DB returns one ingredient
    when(mockDao.getAllIngredients()).thenAnswer((_) => Future.value([
          testIngredient,
        ]));

    await vm.fetchIngredients();

    expect(vm.ingredients.length, 1);
    expect(vm.ingredients.first.id, testIngredient.id);
    expect(vm.ingredientMap![testIngredient.name.trim().toLowerCase()]?.id,
        testIngredient.id);    
  });

  test('fetchIngredients removes local ingredients not in backend', () async {
    final localIngredient = testIngredient.copyWith(id: 'ing2', name: 'Pepper');
    // Backend returns only testIngredient as JSON
    when(mockService.getAllIngredients()).thenAnswer((_) async => [
          testIngredient.toJson(),
        ]);
    // Local DB has extra ingredient
    when(mockDao.getAllIngredients()).thenAnswer((_) => Future.value([
          testIngredient,
          localIngredient,
        ]));
    when(mockDao.insertIngredient(any)).thenAnswer((_) async => 1);
    when(mockDao.deleteIngredient(any)).thenAnswer((_) async => 1);

    await vm.fetchIngredients();

    expect(vm.ingredients.length, 1);
    expect(vm.ingredients.first.id, testIngredient.id);
    verify(mockDao.deleteIngredient('ing2')).called(1);
    verify(mockDao.insertIngredient(any)).called(1);
  });

  test('fetchIngredients does not update DB if backend and local are the same',
      () async {
    // Backend and local DB both have testIngredient as JSON and as model
    when(mockService.getAllIngredients()).thenAnswer((_) async => [
          testIngredient.toJson(),
        ]);
    when(mockDao.getAllIngredients()).thenAnswer((_) => Future.value([
          testIngredient,
        ]));

    await vm.fetchIngredients();

    expect(vm.ingredients.length, 1);
    verifyNever(mockDao.insertIngredient(any));
    verifyNever(mockDao.deleteIngredient(any));
  });
}