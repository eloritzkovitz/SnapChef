import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the user profile when the screen is initialized
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: authViewModel.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading profile data...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : authViewModel.user == null
              ? const Center(
                  child: Text(
                    'Failed to load profile data',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: authViewModel.user?.profilePicture != null
                              ? NetworkImage(authViewModel.getFullImageUrl(authViewModel.user!.profilePicture!)) as ImageProvider
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                        ),
                        const SizedBox(height: 30),

                        // User Full Name
                        Text(
                          authViewModel.user?.fullName ?? 'Unknown User',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // User Email
                        Text(
                          authViewModel.user?.email ?? 'No Email',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),

                        // Edit Profile Button
                        SizedBox(
                          width: 200,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(                              
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Logout Button
                        SizedBox(
                          width: 200,
                          child: ElevatedButton.icon(
                            onPressed: authViewModel.isLoggingOut
                                ? null
                                : () async {
                                    authViewModel.setLoggingOut(true);
                                    await authViewModel.logout(context);
                                    authViewModel.setLoggingOut(false);
                                  },
                            icon: const Icon(Icons.logout),
                            label: Text(authViewModel.isLoggingOut ? 'Logging out...' : 'Logout'),
                            style: ElevatedButton.styleFrom(                              
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}