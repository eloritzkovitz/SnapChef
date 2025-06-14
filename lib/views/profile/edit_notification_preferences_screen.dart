import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/snapchef_appbar.dart';
import '../../theme/colors.dart';
import '../../viewmodels/user_viewmodel.dart';

class EditNotificationPreferencesScreen extends StatefulWidget {
  const EditNotificationPreferencesScreen({super.key});

  @override
  State<EditNotificationPreferencesScreen> createState() =>
      _EditNotificationPreferencesScreenState();
}

class _EditNotificationPreferencesScreenState
    extends State<EditNotificationPreferencesScreen> {
  bool _loading = true;
  bool _friendRequests = true;
  bool _recipeShares = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final prefs = userViewModel.user?.preferences?.notificationPreferences;
      setState(() {
        _friendRequests = prefs?['friendRequests'] ?? true;
        _recipeShares = prefs?['recipeShares'] ?? true;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: SnapChefAppBar(
        title: const Text('Notification Preferences',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Push Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Friend Requests'),
                value: _friendRequests,
                activeColor: primaryColor,
                onChanged: (val) {
                  setState(() => _friendRequests = val);
                },
              ),
              SwitchListTile(
                title: const Text('Recipe Shares'),
                value: _recipeShares,
                activeColor: primaryColor,
                onChanged: (val) {
                  setState(() => _recipeShares = val);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  await userViewModel.updateUserPreferences(
                    notificationPreferences: {
                      'friendRequests': _friendRequests,
                      'recipeShares': _recipeShares,
                    },
                  );
                  if (context.mounted) Navigator.pop(context); // Close loading
                  if (context.mounted) Navigator.pop(context); // Go back
                } catch (e) {
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Failed to update notification preferences: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
