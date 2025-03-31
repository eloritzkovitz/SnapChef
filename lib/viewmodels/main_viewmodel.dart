import 'package:flutter/material.dart';
import '../views/screens/fridge/fridge_screen.dart';
import '../views/screens/cookbook/cookbook_screen.dart';
import '../views/screens/profile/profile_screen.dart';
import '../views/screens/notifications/notifications_screen.dart';

class MainViewModel extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  static List<Widget> widgetOptions = <Widget>[
    const FridgeScreen(),
    const CookbookScreen(),    
    const ProfileScreen(),
    const NotificationsScreen(),
  ];

  Widget get currentScreen => widgetOptions[_selectedIndex];
}