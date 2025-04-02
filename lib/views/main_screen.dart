import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/main_viewmodel.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);

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
              const Text('SnapChef', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )
      : null,
      body: viewModel.currentScreen,      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Cookbook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        currentIndex: viewModel.selectedIndex,
        onTap: viewModel.onItemTapped,
      ),
    );
  }
}