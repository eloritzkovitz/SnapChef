import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';

class MockMainViewModel extends ChangeNotifier implements MainViewModel {
  int _selectedIndex = 0;

  @override
  int get selectedIndex => _selectedIndex;

  @override
  Widget get currentScreen => const SizedBox.shrink();

  @override
  String get appBarTitle => 'Mock Title';

  @override
  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  @override
  Future<void> logout(BuildContext context) async {}
}