import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/favorites_gallery.dart';
import 'widgets/quick_actions.dart';
import '../../theme/colors.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../utils/ui_util.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final userName = userViewModel.user?.firstName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'BerlinSansFBDemi',
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: primaryColor,
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/icon_appbar.png',
                height: 36,
                width: 36,
              ),
              const SizedBox(width: 8),
              const Text('SnapChef'),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${UIUtil().getGreeting()}, $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome back to SnapChef! Let’s get cooking.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const QuickActions(),
            const SizedBox(height: 32),
            // Favorite Recipes Carousel Section
            const FavoritesGallery(),
          ],
        ),
      ),
    );
  }
}