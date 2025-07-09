import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/viewmodels/ingredient_list_controller.dart';
import 'package:snapchef/models/ingredient.dart';

void main() {
  late IngredientListController controller;
  late List<Ingredient> ingredients;

  setUp(() {
    ingredients = [
      Ingredient(name: 'Apple', count: 5, category: 'Fruit', id: '1', imageURL: ''),
      Ingredient(name: 'Banana', count: 2, category: 'Fruit', id: '2', imageURL: ''),
      Ingredient(name: 'Carrot', count: 7, category: 'Vegetable', id: '3', imageURL: ''),
      Ingredient(name: 'Broccoli', count: 3, category: 'Vegetable', id: '4', imageURL: ''),
    ];
    controller = IngredientListController(List<Ingredient>.from(ingredients));
  });

  group('sourceList', () {
    test('returns the source list', () {
      expect(controller.sourceList, ingredients);
    });
  });

  group('filterByCategory', () {
    test('returns true if category is null', () {
      expect(controller.filterByCategory(ingredients[0], null), isTrue);
    });

    test('returns true if category is empty', () {
      expect(controller.filterByCategory(ingredients[0], ''), isTrue);
    });

    test('returns true if item matches category (case-insensitive)', () {
      expect(controller.filterByCategory(ingredients[0], 'fruit'), isTrue);
      expect(controller.filterByCategory(ingredients[2], 'VEGETABLE'), isTrue);
    });

    test('returns false if item does not match category', () {
      expect(controller.filterByCategory(ingredients[0], 'Vegetable'), isFalse);
    });
  });

  group('filterBySearch', () {
    test('returns true if name contains filter (case-insensitive)', () {
      expect(controller.filterBySearch(ingredients[0], 'app'), isTrue);
      expect(controller.filterBySearch(ingredients[1], 'BAN'), isTrue);
    });

    test('returns false if name does not contain filter', () {
      expect(controller.filterBySearch(ingredients[0], 'xyz'), isFalse);
    });
  });

  group('sortItems', () {
    test('sorts by name ascending when sortOption is "Name"', () {
      final result = controller.sortItems(ingredients[0], ingredients[1], 'Name');
      expect(result < 0, isTrue); // 'Apple' < 'Banana'
    });

    test('sorts by quantity descending when sortOption is "Quantity"', () {
      final result = controller.sortItems(ingredients[0], ingredients[1], 'Quantity');
      expect(result < 0, isTrue); // 5 < 2, so b.count - a.count < 0
      // Actually, should be 2 < 5, so b.count (2) - a.count (5) = -3, but your code does b.count.compareTo(a.count)
      // So, for descending, higher count comes first
      expect(controller.sortItems(ingredients[2], ingredients[1], 'Quantity') < 0, isTrue); // 7 > 2
    });

    test('returns 0 for unknown sortOption', () {
      expect(controller.sortItems(ingredients[0], ingredients[1], 'Other'), 0);
      expect(controller.sortItems(ingredients[0], ingredients[1], null), 0);
    });
  });

  group('getCategories', () {
    test('returns sorted unique categories', () {
      final categories = controller.getCategories();
      expect(categories, ['Fruit', 'Vegetable']);
    });

    test('returns empty list if no ingredients', () {
      final emptyController = IngredientListController([]);
      expect(emptyController.getCategories(), isEmpty);
    });
  });

  group('clear', () {
    test('clears the ingredient list and notifies listeners', () {
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });
      controller.clear();
      expect(controller.sourceList, isEmpty);
      expect(notified, isTrue);
    });
  });
}