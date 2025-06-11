import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/snapchef_appbar.dart';
import 'widgets/profile_details.dart';
import '../../models/user.dart' as model;
import '../../viewmodels/user_viewmodel.dart';

class PublicProfileScreen extends StatelessWidget {
  final model.User user;
  const PublicProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) { 
    return ChangeNotifierProvider(
      create: (_) => UserViewModel()..fetchUserStats(userId: user.id),
      child: BaseScreen(
        appBar: SnapChefAppBar(
          title: const Text(
            'View Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,          
          elevation: 1,
        ),        
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ProfileDetails(
              user: user,
              showSettings: false,
              friendsClickable: false,
            ),
          ),
        ),
      ),
    );
  }
}
