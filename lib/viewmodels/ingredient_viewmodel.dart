import 'package:get_it/get_it.dart';
import 'package:snapchef/database/app_database.dart' as db;
import '../core/base_viewmodel.dart';
import '../services/ingredient_service.dart';
import '../database/daos/ingredient_dao.dart';
import '../models/ingredient.dart';

class IngredientViewModel extends BaseViewModel {
  List<Ingredient> _ingredients = [];
  Map<String, Ingredient>? _ingredientMap;

  List<Ingredient> get ingredients => _ingredients;
  Map<String, Ingredient>? get ingredientMap => _ingredientMap;

  final IngredientService _service = GetIt.I<IngredientService>();
  final IngredientDao _ingredientDao = GetIt.I<db.AppDatabase>().ingredientDao;

  /// Fetches all ingredients from the service and updates the state and local DB if changed.
  Future<void> fetchIngredients() async {
    setLoading(true);
    notifyListeners();

    try {
      // Try fetching from backend with a timeout
      final fetchedJson = await _service
          .getAllIngredients()
          .timeout(const Duration(seconds: 3));
      final fetchedIngredients = fetchedJson
          .map<Ingredient>((json) => Ingredient.fromJson(json))
          .toList();

      // Load local ingredients from DB
      final localIngredients = await _ingredientDao.getAllIngredients();

      // Compare by id and content
      final localIngredientsModel = localIngredients
          .map<Ingredient>((e) => Ingredient.fromJson(e.toJson()))
          .toList();
      bool isDifferent = fetchedIngredients.length != localIngredients.length ||
          !_listEqualsByContent(fetchedIngredients, localIngredientsModel);

      if (isDifferent) {
        // Remove local ingredients not in fetched list
        final fetchedIds = fetchedIngredients.map((e) => e.id).toSet();
        for (final local in localIngredients) {
          if (!fetchedIds.contains(local.id)) {
            await _ingredientDao.deleteIngredient(local.id);
          }
        }

        // Insert or update fetched ingredients
        for (final ing in fetchedIngredients) {
          await _ingredientDao.insertIngredient(ing.toCompanion());
        }

        _ingredients = fetchedIngredients;
        _ingredientMap = {
          for (var ing in _ingredients) ing.name.trim().toLowerCase(): ing
        };
      } else {
        _ingredients = localIngredients
            .map<Ingredient>((e) => Ingredient.fromJson(e.toJson()))
            .toList();
        _ingredientMap = {
          for (var ing in _ingredients) ing.name.trim().toLowerCase(): ing
        };
      }
    } catch (e) {
      // Fallback to local DB if backend fails or times out
      final localIngredients = await _ingredientDao.getAllIngredients();
      _ingredients = localIngredients
          .map<Ingredient>((e) => Ingredient.fromJson(e.toJson()))
          .toList();
      _ingredientMap = {
        for (var ing in _ingredients) ing.name.trim().toLowerCase(): ing
      };
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // Helper to compare lists by id and content
  bool _listEqualsByContent(List<Ingredient> a, List<Ingredient> b) {
    if (a.length != b.length) return false;
    final bMap = {for (var ing in b) ing.id: ing};
    for (final ingA in a) {
      final ingB = bMap[ingA.id];
      if (ingB == null ||
          ingA.name != ingB.name ||
          ingA.category != ingB.category ||
          ingA.imageURL != ingB.imageURL ||
          ingA.count != ingB.count) {
        return false;
      }
    }
    return true;
  }

  @override
  void clear() {
    _ingredients = [];
    _ingredientMap = null;
    setLoading(false);
    notifyListeners();
  }
}
