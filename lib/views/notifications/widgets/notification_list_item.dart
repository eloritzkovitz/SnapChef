import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/models/notifications/friend_notification.dart';
import 'package:snapchef/models/notifications/share_notification.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/utils/image_util.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

import '../../../utils/ui_util.dart';

class NotificationListItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onDelete;
  final DismissDirectionCallback? onDismissed;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onDelete,
    this.onDismissed,
    this.confirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    IconData icon;
    Color color;
    Widget leadingWidget;

    if (notification is ShareNotification) {
      icon = Icons.restaurant_menu;
      color = Colors.orange;
      User? sender;
      try {
        sender = userViewModel.friends.firstWhere(
            (u) => u.id == (notification as ShareNotification).senderId);
      } catch (_) {
        sender = null;
      }
      if (sender != null &&
          sender.profilePicture != null &&
          sender.profilePicture!.isNotEmpty) {
        leadingWidget = CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: NetworkImage(
            ImageUtil().getFullImageUrl(sender.profilePicture!),
          ),
        );
      } else {
        leadingWidget = CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child: Image.asset(
              'assets/images/default_profile.png',
              fit: BoxFit.cover,
              width: 36,
              height: 36,
            ),
          ),
        );
      }
    } else if (notification is FriendNotification) {
      icon = Icons.person_add_alt_1;
      color = Colors.green;
      User? friend;
      try {
        friend = userViewModel.friends.firstWhere(
            (u) => u.id == (notification as FriendNotification).senderId);
      } catch (_) {
        friend = null;
      }
      if (friend != null &&
          friend.profilePicture != null &&
          friend.profilePicture!.isNotEmpty) {
        leadingWidget = CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: NetworkImage(
            ImageUtil().getFullImageUrl(friend.profilePicture!),
          ),
        );
      } else {
        leadingWidget = CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child: Image.asset(
              'assets/images/default_profile.png',
              fit: BoxFit.cover,
              width: 36,
              height: 36,
            ),
          ),
        );
      }
    } else {
      icon = Icons.notifications;
      color = Colors.blueGrey;
      leadingWidget = CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: color, size: 20),
      );
    }

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leadingWidget,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (notification.body.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          notification.body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                UIUtil.formatNotificationRelative(notification.scheduledTime),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
