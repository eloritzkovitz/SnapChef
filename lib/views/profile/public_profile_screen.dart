import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_details.dart';
import '../../models/user.dart' as model;
import '../../viewmodels/user_viewmodel.dart';
import '../../database/app_database.dart';
import '../../providers/connectivity_provider.dart';

class PublicProfileScreen extends StatelessWidget {
  final model.User user;
  const PublicProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => UserViewModel(
        database: database,
        connectivityProvider: connectivityProvider,
      )..fetchUserStats(userId: user.id),
      child: Scaffold(
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
      ),
    );
  }
}