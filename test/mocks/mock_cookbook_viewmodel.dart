import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/models/recipe.dart';

class MockCookbookViewModel extends CookbookViewModel {
  @override
  List<Recipe> get filteredItems => [];

  @override
  void applyFiltersAndSorting() {}

  @override
  void clearFilters() {}
}