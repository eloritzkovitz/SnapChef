import 'package:flutter/material.dart';

mixin HelpersMixin on ChangeNotifier {
  // Updates the state and notifies listeners, applying filters if provided.
  void updateAndNotify(VoidCallback update, void Function() applyFilters) {
    update();
    applyFilters();
    notifyListeners();
  }
}