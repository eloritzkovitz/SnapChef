import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final bool isLoading;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const SearchBox({
    super.key,
    required this.labelText,
    this.hintText,
    required this.onChanged,
    this.isLoading = false,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: false,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: hintText,
        prefixIcon: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      ),
      style: const TextStyle(fontSize: 15),
      onChanged: onChanged,
    );
  }
}