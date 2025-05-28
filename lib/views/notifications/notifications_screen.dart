import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/notifications/upcoming_alerts_screen.dart';
import 'friend_requests_screen.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../models/notifications/friend_notification.dart';
import '../../models/notifications/share_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
            final notifications = notificationsViewModel.notifications;
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
                if (notif is FriendNotification) {
                  icon = Icons.person_add_alt_1;
                  color = Colors.green;
                } else if (notif is ShareNotification) {
                  icon = Icons.restaurant_menu;
                  color = Colors.orange;
                } else {
                  icon = Icons.notifications;
                  color = Colors.blueGrey;
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
                        Icon(icon, color: color, size: 32),
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
                          '${notif.scheduledTime.hour.toString().padLeft(2, '0')}:${notif.scheduledTime.minute.toString().padLeft(2, '0')}',
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