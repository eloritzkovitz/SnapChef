import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'widgets/profile_details.dart';

class PublicProfileScreen extends StatelessWidget {
  final User user;
  const PublicProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      backgroundColor: Colors.white,
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
    );
  }
}