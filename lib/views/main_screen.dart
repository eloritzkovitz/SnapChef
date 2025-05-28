import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/main_viewmodel.dart';
import '../viewmodels/fridge_viewmodel.dart';
import '../viewmodels/cookbook_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../views/home/home_screen.dart';
import '../views/fridge/fridge_screen.dart';
import '../views/cookbook/cookbook_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/notifications/notifications_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _hasInitializedFridge = false;
  bool _hasInitializedCookbook = false;

  @override
  void initState() {
    super.initState();
    // Set navigation bar to white for the rest of the app
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize fridge ingredients
    if (!_hasInitializedFridge) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userViewModel = context.read<UserViewModel>();
        final fridgeViewModel = context.read<FridgeViewModel>();

        final fridgeId = userViewModel.fridgeId;
        if (fridgeId != null) {
          fridgeViewModel.fetchFridgeIngredients(fridgeId);
          fridgeViewModel.fetchGroceries(fridgeId);
        }
      });

      _hasInitializedFridge = true;
    }

    // Initialize cookbook recipes
    if (!_hasInitializedCookbook) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authViewModel = context.read<UserViewModel>();
        final cookbookViewModel = context.read<CookbookViewModel>();

        final cookbookId = authViewModel.cookbookId;
        if (cookbookId != null) {
          cookbookViewModel.fetchCookbookRecipes(cookbookId);
        }
      });

      _hasInitializedCookbook = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    // Define the screens for the navigation bar
    final screens = [
      const HomeScreen(),
      const FridgeScreen(),
      const CookbookScreen(),
      const ProfileScreen(),
      const NotificationsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: viewModel.selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Fridge'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Cookbook'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          ],
          currentIndex: viewModel.selectedIndex,
          onTap: viewModel.onItemTapped,
          iconSize: 30,
        ),
      ),
    );
  }
}
