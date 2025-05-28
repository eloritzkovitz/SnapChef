import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/friend_request.dart';
import '../../viewmodels/friend_viewmodel.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../models/notifications/friend_notification.dart';
import '../../viewmodels/user_viewmodel.dart'; // <-- Add this import

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
    final currentUser = Provider.of<UserViewModel>(context, listen: false).user;
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
          // Only show requests with status 'pending' and not sent by current user
          final requests = (snapshot.data ?? [])
              .where((req) =>
                  req.status == 'pending' && req.from.id != currentUser?.id)
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
                        // Add notification for new friendship (to current user)
                        final notificationsViewModel =
                            Provider.of<NotificationsViewModel>(context,
                                listen: false);
                        await notificationsViewModel.addNotification(
                          FriendNotification(
                            id: await notificationsViewModel
                                .generateUniqueNotificationId(),
                            title: 'You are now friends with ${user.fullName}',
                            body:
                                'You and ${user.fullName} can now share recipes!',
                            scheduledTime: DateTime.now(),
                            friendName: user.fullName,
                            userId: currentUser?.id ?? '',
                          ),
                        );
                        // Add notification for the other user (the one who sent the request)
                        await notificationsViewModel.addNotification(
                          FriendNotification(
                            id: await notificationsViewModel
                                .generateUniqueNotificationId(),
                            title:
                                'You are now friends with ${currentUser?.fullName ?? "your friend"}',
                            body:
                                'You and ${currentUser?.fullName ?? "your friend"} can now share recipes!',
                            scheduledTime: DateTime.now(),
                            friendName: currentUser?.fullName ?? "",
                            userId: user.id,
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Friend request accepted')),
                          );
                        }
                        _loadFriendRequests();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await Provider.of<FriendViewModel>(context,
                                listen: false)
                            .respondToRequest(req.id, false, req.to);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Friend request declined')),
                          );
                        }
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
