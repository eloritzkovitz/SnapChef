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
  bool showSentByMe = false;
  final Map<String, User?> _userCache = {};
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    if (userViewModel.user != null) {
      Provider.of<FriendViewModel>(context, listen: false)
          .getAllFriendRequests(userViewModel.user!.id)
          .then((_) => _preloadSentUsers());
    }
  }

  @override
  void didUpdateWidget(covariant FriendRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the widget is rebuilt and the list changes, reload user cache if needed
    _preloadSentUsers();
  }

  Future<void> _preloadSentUsers() async {
    setState(() => _loadingUsers = true);
    final friendViewModel =
        Provider.of<FriendViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final sentRequests = friendViewModel.sentRequests
        .where((req) => req.status == 'pending')
        .toList();
    final missingUserIds = sentRequests
        .map((req) => req.to)
        .where((id) => !_userCache.containsKey(id))
        .toSet();
    for (final userId in missingUserIds) {
      final user = await userViewModel.fetchUserProfile(userId);
      _userCache[userId] = user;
    }
    setState(() => _loadingUsers = false);
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
      body: Consumer2<UserViewModel, FriendViewModel>(
        builder: (context, userViewModel, friendViewModel, _) {
          final currentUser = userViewModel.user;
          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = showSentByMe
              ? friendViewModel.sentRequests
                  .where((req) => req.status == 'pending')
                  .toList()
              : friendViewModel.pendingRequests;

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
                          _preloadSentUsers();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: friendViewModel.isLoading || _loadingUsers
                    ? const Center(child: CircularProgressIndicator())
                    : friendViewModel.error != null
                        ? Center(
                            child: Text(friendViewModel.error!,
                                style: const TextStyle(color: Colors.red)))
                        : requests.isEmpty
                            ? Center(
                                child: Text(
                                  showSentByMe
                                      ? 'You have not sent any friend requests.'
                                      : 'No friend requests.',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: requests.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final req = requests[index];
                                  if (showSentByMe) {
                                    final user = _userCache[req.to];
                                    if (user == null) {
                                      // Should not happen after preload, but fallback
                                      return _buildCardSkeleton();
                                    }
                                    return _buildRequestCard(
                                      context: context,
                                      user: user,
                                      req: req,
                                      showSentByMe: true,
                                      currentUser: currentUser,
                                      friendViewModel: friendViewModel,
                                      userViewModel: userViewModel,
                                    );
                                  } else {
                                    return _buildRequestCard(
                                      context: context,
                                      user: req.from,
                                      req: req,
                                      showSentByMe: false,
                                      currentUser: currentUser,
                                      friendViewModel: friendViewModel,
                                      userViewModel: userViewModel,
                                    );
                                  }
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
            color: Colors.black.withAlpha(10),
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

  Widget _buildRequestCard({
    required BuildContext context,
    required User user,
    required FriendRequest req,
    required bool showSentByMe,
    required User currentUser,
    required FriendViewModel friendViewModel,
    required UserViewModel userViewModel,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
                    await friendViewModel.respondToRequest(
                        req.id, false, currentUser.id, userViewModel);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Friend request cancelled')),
                      );
                    }
                    // Refresh requests and user cache
                    if (context.mounted) {
                      await Provider.of<FriendViewModel>(context, listen: false)
                          .getAllFriendRequests(currentUser.id);
                    }
                    await _preloadSentUsers();
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
                        await friendViewModel.respondToRequest(
                            req.id, true, currentUser.id, userViewModel);
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
                            senderId: currentUser.id,
                            recipientId: user.id,
                          ),
                          currentUser.id,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Friend request accepted')),
                          );
                        }
                        // Refresh requests and user cache
                        if (context.mounted) {
                          await Provider.of<FriendViewModel>(context,
                                  listen: false)
                              .getAllFriendRequests(currentUser.id);
                        }
                        await _preloadSentUsers();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await friendViewModel.respondToRequest(
                            req.id, false, currentUser.id, userViewModel);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Friend request declined')),
                          );
                        }
                        // Refresh requests and user cache
                        if (context.mounted) {
                          await Provider.of<FriendViewModel>(context,
                                  listen: false)
                              .getAllFriendRequests(currentUser.id);
                          await _preloadSentUsers();
                        }
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
