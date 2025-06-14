import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ingredient_viewmodel.dart';
import '../home/home_screen.dart';
import '../fridge/fridge_screen.dart';
import '../cookbook/cookbook_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../providers/connectivity_provider.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/offline_banner.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {  
  bool? _wasOffline;

  @override
  void initState() {
    super.initState();
    // Listen for FCM token refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserViewModel>(context, listen: false)
          .listenForFcmTokenRefresh();

      // Fetch ingredients once when main screen is loaded
      Provider.of<IngredientViewModel>(context, listen: false).fetchIngredients();

      // Show offline snackbar if entering main screen and already offline
      final isOffline =
          Provider.of<ConnectivityProvider>(context, listen: false).isOffline;
      if (isOffline) {
        UIUtil.showOffline(context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check connectivity status and show appropriate banner
    final isOffline = context.watch<ConnectivityProvider>().isOffline;
    if (_wasOffline != null && _wasOffline != isOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (isOffline) {
          UIUtil.showOffline(context);
        } else {
          UIUtil.showBackOnline(context);
        }
      });
    }
    _wasOffline = isOffline;    
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    final screens = [
      const HomeScreen(),
      const FridgeScreen(),
      const CookbookScreen(),
      const ProfileScreen(),
      const NotificationsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: viewModel.selectedIndex,
            children: screens,
          ),
          // Offline banner
          if (isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: OfflineBanner(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Fridge'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book), label: 'Cookbook'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
          ],
          currentIndex: viewModel.selectedIndex,
          onTap: viewModel.onItemTapped,
          iconSize: 30,
        ),
      ),
    );
  }
}
