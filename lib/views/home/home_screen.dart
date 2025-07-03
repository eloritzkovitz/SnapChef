import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/favorites_gallery.dart';
import 'widgets/quick_actions.dart';
import '../../providers/connectivity_provider.dart';
import '../../theme/colors.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/user_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  final CarouselSliderController? carouselController;

  const HomeScreen({super.key, this.carouselController});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final userName = userViewModel.user?.firstName ?? 'User';
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOffline) const SizedBox(height: 40),
            const SizedBox(height: 24),
            Row(
              children: [
                Image.asset(
                  'assets/images/icon_appbar.png',
                  height: 36,
                  width: 36,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SnapChef',
                  style: TextStyle(
                    fontFamily: 'BerlinSansFBDemi',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
              const SizedBox(height: 8),
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
              FavoritesGallery(carouselController: carouselController),
            ],
          ),
        ),
      ),
    );
  }
}