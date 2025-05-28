import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/notifications/upcoming_alerts_screen.dart';
import 'friend_requests_screen.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../models/notifications/friend_notification.dart';
import '../../models/notifications/share_notification.dart';
import '../../models/user.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/user_viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Friend Requests',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendRequestsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.alarm),
            tooltip: 'Upcoming Alerts',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<NotificationsViewModel>(
          builder: (context, notificationsViewModel, child) {
            // Sort notifications by scheduledTime descending (most recent first)
            final notifications = List.of(notificationsViewModel.notifications)
              ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

            if (notificationsViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                IconData icon;
                Color color;
                Widget leadingWidget;

                if (notif is ShareNotification) {
                  icon = Icons.restaurant_menu;
                  color = Colors.orange;
                  // Use senderId to get the sender's profile
                  User? sender;
                  try {
                    sender = userViewModel.friends
                        .firstWhere((u) => u.id == notif.senderId);
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
                } else if (notif is FriendNotification) {
                  icon = Icons.person_add_alt_1;
                  color = Colors.green;
                  User? friend;
                  try {
                    friend = userViewModel.friends
                        .firstWhere((u) => u.fullName == notif.friendName);
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

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
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
                                notif.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (notif.body.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    notif.body,
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
                          '${notif.scheduledTime.toLocal().hour.toString().padLeft(2, '0')}:${notif.scheduledTime.toLocal().minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}