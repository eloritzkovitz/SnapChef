import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/friend_request.dart';
import '../../viewmodels/friend_viewmodel.dart';
import '../../utils/image_util.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  late Future<List<FriendRequest>> _friendRequestsFuture;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  void _loadFriendRequests() {
    final friendViewModel =
        Provider.of<FriendViewModel>(context, listen: false);
    _friendRequestsFuture = friendViewModel.fetchFriendRequests();
    setState(() {}); // Ensure the FutureBuilder rebuilds with the new future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<FriendRequest>>(
        future: _friendRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading friend requests'));
          }
          // Only show requests with status 'pending'
          final requests = (snapshot.data ?? [])
              .where((req) => req.status == 'pending')
              .toList();
          if (requests.isEmpty) {
            return const Center(child: Text('No friend requests.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final user = req.from;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (user.profilePicture != null &&
                          user.profilePicture!.isNotEmpty)
                      ? NetworkImage(
                          ImageUtil().getFullImageUrl(user.profilePicture!))
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
                ),
                title: Text(user.fullName),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await Provider.of<FriendViewModel>(context,
                                listen: false)
                            .respondToRequest(req.id, true, req.to);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Friend request accepted')),
                        );
                        _loadFriendRequests();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await Provider.of<FriendViewModel>(context,
                                listen: false)
                            .respondToRequest(req.id, false, req.to);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Friend request declined')),
                        );
                        _loadFriendRequests();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}