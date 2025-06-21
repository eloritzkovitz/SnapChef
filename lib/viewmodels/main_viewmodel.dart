import 'package:flutter/material.dart';
import '../constants/navigation_constants.dart';
import '../core/base_viewmodel.dart';
import '../views/fridge/fridge_screen.dart';
import '../views/cookbook/cookbook_screen.dart';
import '../views/home/home_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/notifications/notifications_screen.dart';

class MainViewModel extends BaseViewModel {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FridgeScreen(),
    const CookbookScreen(),
    const ProfileScreen(),
    const NotificationsScreen(),
  ];

  int get selectedIndex => _selectedIndex;
  Widget get currentScreen => _screens[_selectedIndex];
  String get appBarTitle => mainScreenTitles[_selectedIndex];

  /// Handles the navigation when an item is tapped in the bottom navigation bar.
  /// Updates the selected index and notifies listeners to rebuild the UI.
  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  @override
  void clear() {
    _selectedIndex = 0;
    notifyListeners();
  }
}
