import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:snapchef/utils/sort_filter_mixin.dart';

class TestItem {
  final String name;
  final String category;
  TestItem(this.name, this.category);
}

class TestViewModel extends ChangeNotifier with SortFilterMixin<TestItem> {
  @override
  List<TestItem> sourceList = [
    TestItem('Apple', 'Fruit'),
    TestItem('Banana', 'Fruit'),
    TestItem('Carrot', 'Vegetable'),
  ];

  @override
  bool filterByCategory(TestItem item, String? category) =>
      item.category == category;

  @override
  bool filterBySearch(TestItem item, String filter) =>
      item.name.toLowerCase().contains(filter.toLowerCase());

  @override
  int sortItems(TestItem a, TestItem b, String? sortOption) =>
      a.name.compareTo(b.name);
}

void main() {
  group('SortFilterMixin', () {
    late TestViewModel vm;

    setUp(() {
      vm = TestViewModel();
    });

    test('filters by category', () {
      vm.filterByCategoryValue('Fruit');
      expect(vm.filteredItems.length, 2);
    });

    test('filters by search', () {
      vm.setFilter('car');
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.name, 'Carrot');
    });

    test('sorts items', () {
      vm.sortByOption('name');
      expect(vm.filteredItems.first.name, 'Apple');
    });

    test('clearFilters resets filters', () {
      vm.setFilter('car');
      vm.clearFilters();
      expect(vm.filteredItems.length, 3);
    });
  });
}