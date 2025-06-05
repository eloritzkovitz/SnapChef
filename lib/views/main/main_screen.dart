import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import '../fridge/fridge_screen.dart';
import '../cookbook/cookbook_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../providers/connectivity_provider.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/ingredient_viewmodel.dart';

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
    // Listen for FCM token refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserViewModel>(context, listen: false).listenForFcmTokenRefresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize fridge ingredients
    if (!_hasInitializedFridge) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final userViewModel = context.read<UserViewModel>();
        final fridgeViewModel = context.read<FridgeViewModel>();
        final ingredientViewModel =
            Provider.of<IngredientViewModel>(context, listen: false);

        final fridgeId = userViewModel.fridgeId;
        if (fridgeId != null) {
          await ingredientViewModel.fetchIngredients();
          fridgeViewModel.fetchFridgeIngredients(fridgeId, ingredientViewModel);
          fridgeViewModel.fetchGroceries(fridgeId, ingredientViewModel);
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
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    // Define the screens for the navigation bar
    final screens = [
      const HomeScreen(),
      const FridgeScreen(),
      const CookbookScreen(),
      const ProfileScreen(),
      const NotificationsScreen(),
    ];

    return Column(
      children: [
        if (isOffline)
          MaterialBanner(
            content: const Text(
              'You are offline',
              style: TextStyle(color: Colors.black87),
            ),
            backgroundColor: Colors.grey,
            actions: [Container()],
          ),
        Expanded(
          child: Scaffold(
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
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.kitchen), label: 'Fridge'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book), label: 'Cookbook'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profile'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.notifications), label: 'Notifications'),
                ],
                currentIndex: viewModel.selectedIndex,
                onTap: viewModel.onItemTapped,
                iconSize: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
