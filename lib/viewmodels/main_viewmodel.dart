import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/main_screen.dart';
import '../views/cookbook/cookbook_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/notifications/notifications_screen.dart';

class MainViewModel extends ChangeNotifier {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MainScreen(),
    const CookbookScreen(),
    const ProfileScreen(),
    const NotificationsScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Cookbook',
    'Profile',
    'Notifications',
  ];

  int get selectedIndex => _selectedIndex;
  Widget get currentScreen => _screens[_selectedIndex];
  String get appBarTitle => _titles[_selectedIndex];

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored tokens
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
  }
}