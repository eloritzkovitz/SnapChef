import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

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

    return authViewModel.isLoading
        ? const Center(child: CircularProgressIndicator())
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
                        radius: 80, // Larger profile picture
                        backgroundImage: authViewModel.user?.profilePicture != null
                            ? NetworkImage(authViewModel.user!.profilePicture!)
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
                    ],
                  ),
                ),
              );
  }
}