import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class FilterSortSheet extends StatefulWidget {
  final String selectedCategory;
  final String selectedSort;
  final List<String> categories;
  final void Function() onClear;
  final void Function(String category, String sort) onApply;
  final String categoryLabel;
  final String sortLabel;

  const FilterSortSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedSort,
    required this.categories,
    required this.onClear,
    required this.onApply,
    this.categoryLabel = 'Category',
    this.sortLabel = 'Sort By',
  });

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late String selectedCategory;
  late String selectedSort;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    selectedSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories.where((e) => e.trim().isNotEmpty).toSet().toList();

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
            // Category filter
            DropdownButtonFormField<String>(
              value: categories.contains(selectedCategory) ? selectedCategory : '',
              decoration: InputDecoration(
                labelText: widget.categoryLabel,
                prefixIcon: Icon(Icons.category, color: primaryColor),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('All Categories')),
                ...categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(cat),
                    ],
                  ),
                )),
              ],
              onChanged: (val) => setState(() => selectedCategory = val ?? ''),
            ),
            const SizedBox(height: 18),
            // Sort
            DropdownButtonFormField<String>(
              value: selectedSort,
              decoration: InputDecoration(
                labelText: widget.sortLabel,
                prefixIcon: Icon(Icons.sort, color: primaryColor),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('No Sorting')),
                DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                DropdownMenuItem(value: 'Quantity', child: Text('Sort by Quantity')),
              ],
              onChanged: (val) => setState(() => selectedSort = val ?? ''),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.clear, color: primaryColor),
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check, color: Colors.white),
                    onPressed: () {
                      widget.onApply(selectedCategory, selectedSort);
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