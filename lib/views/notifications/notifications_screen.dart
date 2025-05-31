import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/notifications/upcoming_alerts_screen.dart';
import './friend_requests_screen.dart';
import '../../models/notifications/app_notification.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../widgets/snapchef_appbar.dart';
import 'widgets/notification_list_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  AppNotification? _recentlyDeleted;
  Timer? _undoTimer;

  @override
  void dispose() {
    _undoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {   

    return Scaffold(
      appBar: SnapChefAppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                return NotificationListItem(
                  notification: notif,
                  confirmDismiss: (direction) async {
                    _recentlyDeleted = notif;
                    return true;
                  },
                  onDismissed: (direction) async {
                    final viewModel = Provider.of<NotificationsViewModel>(context, listen: false);
                    await viewModel.deleteNotification(notif.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification removed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () async {
                              if (_recentlyDeleted != null) {
                                await viewModel.addNotification(_recentlyDeleted!);
                                _recentlyDeleted = null;
                              }
                            },
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }

                    _undoTimer?.cancel();
                    _undoTimer = Timer(const Duration(seconds: 5), () {
                      _recentlyDeleted = null;
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}