import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/main_view_model.dart';
import '../widgets/action_button.dart';

class MainScreen extends StatelessWidget {
  
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SnapChef')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: viewModel.currentScreen,
            ),
          ),
        ],
      ),
      floatingActionButton: viewModel.selectedIndex == 0 ? const ActionButton() : null,
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