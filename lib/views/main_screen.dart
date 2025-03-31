import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/main_viewmodel.dart';
import 'fridge/widgets/action_button.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.appBarTitle),
        actions: [
          if (viewModel.selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                viewModel.logout(context);
              },
            ),
        ],
      ),
      body: viewModel.currentScreen,
      floatingActionButton: viewModel.selectedIndex == 0
          ? const ActionButton()
          : null, // Show FAB only on the Home screen
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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