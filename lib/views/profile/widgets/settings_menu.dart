import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../edit_profile_screen.dart';
import '../edit_preferences_screen.dart';
import '../edit_notification_preferences_screen.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,            
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Settings Header with Close Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Menu Items
              _buildMenuItem(
                context: context,
                icon: Icons.person,
                text: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  _openSlidingScreen(context, const EditProfileScreen());
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.restaurant_menu,
                text: 'Preferences',
                onTap: () {
                  Navigator.pop(context); 
                  _openSlidingScreen(context, const EditPreferencesScreen());         
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.notifications,
                text: 'Notifications',
                onTap: () {
                  Navigator.pop(context);     
                  _openSlidingScreen(context, const EditNotificationPreferencesScreen());            
                },
              ),
              const Divider(),
              _buildMenuItem(
                context: context,
                icon: Icons.logout,
                text: 'Logout',
                onTap: () async {
                  Navigator.pop(context);
                  final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                  authViewModel.setLoggingOut(true);
                  await authViewModel.logout(context);
                  authViewModel.setLoggingOut(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _openSlidingScreen(BuildContext context, Widget screen) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54, // Background overlay color
      transitionDuration: const Duration(milliseconds: 300), // Animation duration
      pageBuilder: (context, animation, secondaryAnimation) {
        return screen; // The screen to open
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start off-screen (right)
        const end = Offset(0.0, 0.0); // End at its final position
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}