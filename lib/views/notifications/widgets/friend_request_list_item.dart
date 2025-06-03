import 'package:flutter/material.dart';
import '../../../models/friend_request.dart';
import '../../../models/user.dart';
import '../../../utils/image_util.dart';
import '../../../viewmodels/friend_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../viewmodels/notifications_viewmodel.dart';
import '../../../models/notifications/friend_notification.dart';
import 'package:provider/provider.dart';

class FriendRequestListItem extends StatelessWidget {
  final User user;
  final FriendRequest req;
  final bool showSentByMe;
  final User currentUser;
  final FriendViewModel friendViewModel;
  final UserViewModel userViewModel;
  final VoidCallback onRefresh;
  final Future<void> Function() preloadSentUsers;

  const FriendRequestListItem({
    super.key,
    required this.user,
    required this.req,
    required this.showSentByMe,
    required this.currentUser,
    required this.friendViewModel,
    required this.userViewModel,
    required this.onRefresh,
    required this.preloadSentUsers,
  });

  @override
  Widget build(BuildContext context) {
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
            backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                ? NetworkImage(ImageUtil().getFullImageUrl(user.profilePicture!))
                : const AssetImage('assets/images/default_profile.png') as ImageProvider,
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
                    await friendViewModel.cancelFriendRequest(
                        req.id, currentUser.id, userViewModel);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Friend request cancelled')),
                      );
                    }
                    if (context.mounted) {
                      onRefresh();
                    }
                    await preloadSentUsers();
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        final notificationsViewModel =
                            Provider.of<NotificationsViewModel>(context, listen: false);
                        await friendViewModel.respondToRequest(
                            req.id, true, currentUser.id, userViewModel);
                        await notificationsViewModel.addNotification(
                          FriendNotification(
                            id: await notificationsViewModel.generateUniqueNotificationId(),
                            title: 'You are now friends with ${currentUser.fullName}',
                            body: 'You and ${currentUser.fullName} can now share recipes!',
                            scheduledTime: DateTime.now(),
                            friendName: currentUser.fullName,
                            senderId: currentUser.id,
                            recipientId: user.id,
                          ),
                          currentUser.id,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Friend request accepted')),
                          );
                        }
                        if (context.mounted) {
                          onRefresh();
                        }
                        await preloadSentUsers();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await friendViewModel.respondToRequest(
                            req.id, false, currentUser.id, userViewModel);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Friend request declined')),
                          );
                        }
                        if (context.mounted) {
                          onRefresh();
                          await preloadSentUsers();
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