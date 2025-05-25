import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/notifications/upcoming_alerts_screen.dart';
import '../../viewmodels/friend_viewmodel.dart';
import '../../models/friend_request.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<FriendRequest>> _friendRequestsFuture;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  void _loadFriendRequests() {
    final friendViewModel = Provider.of<FriendViewModel>(context, listen: false);
    _friendRequestsFuture = friendViewModel.fetchFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpcomingAlertsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Friend Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FutureBuilder<List<FriendRequest>>(
              future: _friendRequestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading friend requests'));
                }
                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return const Center(child: Text('No friend requests.'));
                }
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: req.from.profilePicture != null
                            ? NetworkImage(req.from.profilePicture!)
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider,
                      ),
                      title: Text(req.from.fullName),
                      subtitle: Text(req.from.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await Provider.of<FriendViewModel>(context,
                                      listen: false)
                                  .respondToRequest(req.id, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Friend request accepted')),
                              );
                              setState(() {
                                _loadFriendRequests();
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await Provider.of<FriendViewModel>(context,
                                      listen: false)
                                  .respondToRequest(req.id, false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Friend request declined')),
                              );
                              setState(() {
                                _loadFriendRequests();
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
