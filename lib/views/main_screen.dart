import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/main_viewmodel.dart';
import '../viewmodels/fridge_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _hasInitializedFridge = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedFridge) {      
      final authViewModel = context.read<AuthViewModel>();
      final fridgeViewModel = context.read<FridgeViewModel>();

      final fridgeId = authViewModel.fridgeId;
      if (fridgeId != null) {
        fridgeViewModel.fetchFridgeIngredients(fridgeId);
      }

      _hasInitializedFridge = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    return Scaffold(
      appBar: viewModel.selectedIndex == 0 || viewModel.selectedIndex == 1
          ? AppBar(
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/icon_appbar.png',
                    height: 36,
                    width: 36,
                  ),
                  const SizedBox(width: 8),
                  const Text('SnapChef',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],                
              ),
              backgroundColor: Colors.white,
            )
          : null,
      body: viewModel.currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Cookbook'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        ],
        currentIndex: viewModel.selectedIndex,
        onTap: viewModel.onItemTapped,
      ),
    );
  }
}
