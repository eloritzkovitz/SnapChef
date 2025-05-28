import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/friend_request.dart';
import '../../viewmodels/friend_viewmodel.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../models/notifications/friend_notification.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../models/user.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  late Future<List<FriendRequest>> _friendRequestsFuture;
  bool showSentByMe = false;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  void _loadFriendRequests() {
    final friendViewModel =
        Provider.of<FriendViewModel>(context, listen: false);
    _friendRequestsFuture = friendViewModel.fetchFriendRequests();
    if (mounted) setState(() {});
  }

  Future<User?> _getUserById(BuildContext context, String userId) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return await userViewModel.fetchUserProfile(userId);
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
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, _) {
          final currentUser = userViewModel.user;
          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Requests to me'),
                      selected: !showSentByMe,
                      onSelected: (selected) {
                        if (showSentByMe && selected) {
                          setState(() => showSentByMe = false);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Requests by me'),
                      selected: showSentByMe,
                      onSelected: (selected) {
                        if (!showSentByMe && selected) {
                          setState(() => showSentByMe = true);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<FriendRequest>>(
                  future: _friendRequestsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error loading friend requests'));
                    }
                    final allRequests = snapshot.data ?? [];

                    // Filter requests based on toggle
                    final requests = showSentByMe
                        ? allRequests
                            .where((req) =>
                                req.status == 'pending' &&
                                req.from.id == currentUser.id)
                            .toList()
                        : allRequests
                            .where((req) =>
                                req.status == 'pending' &&
                                req.to == currentUser.id)
                            .toList();

                    if (requests.isEmpty) {
                      return Center(
                        child: Text(
                          showSentByMe
                              ? 'You have not sent any friend requests.'
                              : 'No friend requests.',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final req = requests[index];

                        // For requests sent by me, fetch the "to" user by ID.
                        // For requests to me, use the "from" user object.
                        if (showSentByMe) {
                          return FutureBuilder<User?>(
                            future: _getUserById(context, req.to),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildCardSkeleton();
                              }
                              final user = userSnapshot.data;
                              if (user == null) {
                                return _buildCardError();
                              }
                              return _buildRequestCard(
                                context: context,
                                user: user,
                                req: req,
                                showSentByMe: true,
                                currentUser: currentUser,
                              );
                            },
                          );
                        } else {
                          // Requests to me: use req.from (already a User)
                          return _buildRequestCard(
                            context: context,
                            user: req.from,
                            req: req,
                            showSentByMe: false,
                            currentUser: currentUser,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 12),
                SizedBox(
                  width: 120,
                  height: 18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey,
            child: Icon(Icons.error),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Text('User not found'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard({
    required BuildContext context,
    required User user,
    required FriendRequest req,
    required bool showSentByMe,
    required User currentUser,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                    ? NetworkImage(
                        ImageUtil().getFullImageUrl(user.profilePicture!))
                    : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),                
              ],
            ),
          ),
          showSentByMe
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Cancel request',
                  onPressed: () async {
                    await Provider.of<FriendViewModel>(context, listen: false)
                        .respondToRequest(req.id, false, currentUser.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Friend request cancelled')),
                      );
                    }
                    _loadFriendRequests();
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        final notificationsViewModel =
                            Provider.of<NotificationsViewModel>(context,
                                listen: false);
                        await Provider.of<FriendViewModel>(context,
                                listen: false)
                            .respondToRequest(req.id, true, currentUser.id);
                        // Add notification for new friendship (to current user)
                        await notificationsViewModel.addNotification(
                          FriendNotification(
                            id: await notificationsViewModel
                                .generateUniqueNotificationId(),
                            title: 'You are now friends with ${user.fullName}',
                            body:
                                'You and ${user.fullName} can now share recipes!',
                            scheduledTime: DateTime.now(),
                            friendName: user.fullName,
                            userId: currentUser.id,
                          ),
                        );
                        // Add notification for the other user (the one who sent the request)
                        await notificationsViewModel.addNotification(
                          FriendNotification(
                            id: await notificationsViewModel
                                .generateUniqueNotificationId(),
                            title:
                                'You are now friends with ${currentUser.fullName}',
                            body:
                                'You and ${currentUser.fullName} can now share recipes!',
                            scheduledTime: DateTime.now(),
                            friendName: currentUser.fullName,
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
                            .respondToRequest(req.id, false, currentUser.id);
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
        ],
      ),
    );
  }
}
