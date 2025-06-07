import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/cookbook_viewmodel.dart';
import '../../../theme/colors.dart';

class CookbookFilterSortSheet extends StatefulWidget {
  const CookbookFilterSortSheet({super.key});

  @override
  State<CookbookFilterSortSheet> createState() =>
      _CookbookFilterSortSheetState();
}

class _CookbookFilterSortSheetState extends State<CookbookFilterSortSheet> {
  late String selectedCategory;
  late String selectedCuisine;
  late String selectedDifficulty;
  late RangeValues prepTimeRange;
  late RangeValues cookingTimeRange;
  late RangeValues ratingRange;
  late String selectedSort;
  late String selectedSource;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CookbookViewModel>(context, listen: false);
    selectedCategory = vm.selectedCategory ?? '';
    selectedCuisine = vm.selectedCuisine ?? '';
    selectedDifficulty = vm.selectedDifficulty ?? '';
    prepTimeRange = vm.prepTimeRange ??
        RangeValues(vm.minPrepTime.toDouble(), vm.maxPrepTime.toDouble());
    cookingTimeRange = vm.cookingTimeRange ??
        RangeValues(vm.minCookingTime.toDouble(), vm.maxCookingTime.toDouble());
    ratingRange = vm.ratingRange ?? RangeValues(vm.minRating, vm.maxRating);
    selectedSort = vm.selectedSortOption ?? '';
    selectedSource = vm.selectedSource ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CookbookViewModel>(context, listen: false);

    // Remove empty/duplicate values for dropdowns
    final categories =
        vm.getCategories().where((e) => e.trim().isNotEmpty).toSet().toList();
    final cuisines =
        vm.getCuisines().where((e) => e.trim().isNotEmpty).toSet().toList();
    final difficulties =
        vm.getDifficulties().where((e) => e.trim().isNotEmpty).toSet().toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Meal Type
            DropdownButtonFormField<String>(
              value:
                  categories.contains(selectedCategory) ? selectedCategory : '',
              decoration: InputDecoration(
                labelText: 'Meal Type',
                prefixIcon: Icon(Icons.restaurant, color: primaryColor),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text('All Meal Types')),
                ...categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text(cat),
                        ],
                      ),
                    )),
              ],
              onChanged: (val) => setState(() => selectedCategory = val ?? ''),
            ),
            SizedBox(height: 12),
            // Cuisine
            DropdownButtonFormField<String>(
              value: cuisines.contains(selectedCuisine) ? selectedCuisine : '',
              decoration: InputDecoration(
                labelText: 'Cuisine',
                prefixIcon: Icon(Icons.room_service, color: primaryColor),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text('All Cuisines')),
                ...cuisines.map((cuisine) => DropdownMenuItem(
                      value: cuisine,
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text(cuisine),
                        ],
                      ),
                    )),
              ],
              onChanged: (val) => setState(() => selectedCuisine = val ?? ''),
            ),
            SizedBox(height: 12),
            // Difficulty
            DropdownButtonFormField<String>(
              value: difficulties.contains(selectedDifficulty)
                  ? selectedDifficulty
                  : '',
              decoration: InputDecoration(
                labelText: 'Difficulty',
                prefixIcon: Icon(Icons.emoji_events, color: primaryColor),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text('All Difficulties')),
                ...difficulties.map((diff) => DropdownMenuItem(
                      value: diff,
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text(diff),
                        ],
                      ),
                    )),
              ],
              onChanged: (val) =>
                  setState(() => selectedDifficulty = val ?? ''),
            ),
            SizedBox(height: 18),
            // Source filter
            DropdownButtonFormField<String>(
              value: selectedSource,
              decoration: InputDecoration(
                labelText: 'Source',
                prefixIcon: Icon(Icons.source, color: primaryColor),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('All Sources')),
                DropdownMenuItem(value: 'ai', child: Text('AI-generated')),
                DropdownMenuItem(value: 'user', child: Text('User-made')),
              ],
              onChanged: (val) => setState(() => selectedSource = val ?? ''),
            ),
            SizedBox(height: 18),
            // Prep Time
            Row(
              children: [
                Icon(Icons.access_time, color: primaryColor),
                SizedBox(width: 8),
                Text('Prep Time (min)'),
              ],
            ),
            RangeSlider(
              values: prepTimeRange,
              min: vm.minPrepTime.toDouble(),
              max: vm.maxPrepTime.toDouble() > vm.minPrepTime.toDouble()
                  ? vm.maxPrepTime.toDouble()
                  : vm.minPrepTime.toDouble() + 1,
              divisions: (vm.maxPrepTime - vm.minPrepTime).clamp(1, 100),
              labels: RangeLabels(
                prepTimeRange.start.round().toString(),
                prepTimeRange.end.round().toString(),
              ),
              activeColor: primaryColor,
              onChanged: (range) => setState(() => prepTimeRange = range),
            ),
            SizedBox(height: 12),
            // Cooking Time
            Row(
              children: [
                Icon(Icons.timer, color: primaryColor),
                SizedBox(width: 8),
                Text('Cooking Time (min)'),
              ],
            ),
            RangeSlider(
              values: cookingTimeRange,
              min: vm.minCookingTime.toDouble(),
              max: vm.maxCookingTime.toDouble() > vm.minCookingTime.toDouble()
                  ? vm.maxCookingTime.toDouble()
                  : vm.minCookingTime.toDouble() + 1,
              divisions: (vm.maxCookingTime - vm.minCookingTime).clamp(1, 100),
              labels: RangeLabels(
                cookingTimeRange.start.round().toString(),
                cookingTimeRange.end.round().toString(),
              ),
              activeColor: primaryColor,
              onChanged: (range) => setState(() => cookingTimeRange = range),
            ),
            SizedBox(height: 12),
            // Rating
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700]),
                SizedBox(width: 8),
                Text('Rating'),
              ],
            ),
            RangeSlider(
              values: ratingRange,
              min: vm.minRating,
              max:
                  vm.maxRating > vm.minRating ? vm.maxRating : vm.minRating + 1,
              divisions:
                  ((vm.maxRating - vm.minRating) * 10).clamp(1, 50).toInt(),
              labels: RangeLabels(
                ratingRange.start.toStringAsFixed(1),
                ratingRange.end.toStringAsFixed(1),
              ),
              activeColor: Colors.amber[700],
              onChanged: (range) => setState(() => ratingRange = range),
            ),
            SizedBox(height: 12),
            // Sort
            DropdownButtonFormField<String>(
              value: selectedSort,
              decoration: InputDecoration(
                labelText: 'Sort By',
                prefixIcon: Icon(Icons.sort, color: primaryColor),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('No Sorting')),
                DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                DropdownMenuItem(
                    value: 'Rating', child: Text('Sort by Rating')),
                DropdownMenuItem(
                    value: 'PrepTime', child: Text('Sort by Prep Time')),
                DropdownMenuItem(
                    value: 'CookingTime', child: Text('Sort by Cooking Time')),
              ],
              onChanged: (val) => setState(() => selectedSort = val ?? ''),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      vm.clearFilters();
                      Navigator.pop(context);
                    },
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      vm.selectedCategory =
                          selectedCategory.isEmpty ? null : selectedCategory;
                      vm.selectedCuisine =
                          selectedCuisine.isEmpty ? null : selectedCuisine;
                      vm.selectedDifficulty = selectedDifficulty.isEmpty
                          ? null
                          : selectedDifficulty;
                      vm.prepTimeRange = prepTimeRange;
                      vm.cookingTimeRange = cookingTimeRange;
                      vm.ratingRange = ratingRange;
                      vm.selectedSource =
                          selectedSource.isEmpty ? null : selectedSource;
                      vm.selectedSortOption =
                          selectedSort.isEmpty ? null : selectedSort;
                      vm.applyFiltersAndSorting();
                      Navigator.pop(context);
                    },
                    label: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
