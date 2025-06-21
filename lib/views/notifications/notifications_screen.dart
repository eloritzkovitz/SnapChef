import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/notification_list_item.dart';
import './friend_requests_screen.dart';
import '../../models/notifications/app_notification.dart';
import '../../providers/connectivity_provider.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../views/notifications/upcoming_alerts_screen.dart';
import '../../widgets/snapchef_appbar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  AppNotification? _recentlyDeleted;
  Timer? _undoTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchNotifications();
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    super.dispose();
  }

  // Fetch notifications when the screen is initialized
  void _fetchNotifications() {
    final notificationsViewModel =
        Provider.of<NotificationsViewModel>(context, listen: false);
    notificationsViewModel.syncNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = Provider.of<ConnectivityProvider>(context).isOffline;

    return Scaffold(
      appBar: SnapChefAppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Friend Requests',
            onPressed: isOffline
                ? null
                : () {
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
      body: isOffline
          ? const Center(
              child: Text(
                'Notifications are unavailable offline.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<NotificationsViewModel>(
                builder: (context, notificationsViewModel, child) {
                  final notifications = List.of(
                      notificationsViewModel.notifications)
                    ..sort(
                        (a, b) => b.scheduledTime.compareTo(a.scheduledTime));

                  // Show error message if present
                  if (notificationsViewModel.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Failed to load notifications.',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Swipe down to refresh notifications
                  return RefreshIndicator(
                    onRefresh: () async {
                      await notificationsViewModel.syncNotifications();
                    },
                    child: notificationsViewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : notifications.isEmpty
                            ? const Center(
                                child: Text(
                                  'No notifications',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: notifications.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final notif = notifications[index];
                                  return NotificationListItem(
                                    notification: notif,
                                    confirmDismiss: (direction) async {
                                      _recentlyDeleted = notif;
                                      return true;
                                    },
                                    onDismissed: (direction) async {
                                      final viewModel =
                                          Provider.of<NotificationsViewModel>(
                                              context,
                                              listen: false);
                                      await viewModel
                                          .deleteNotification(notif.id);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Notification removed'),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () async {
                                                if (_recentlyDeleted != null) {
                                                  await viewModel
                                                      .addNotification(
                                                          _recentlyDeleted!);
                                                  _recentlyDeleted = null;
                                                }
                                              },
                                            ),
                                            duration:
                                                const Duration(seconds: 4),
                                          ),
                                        );
                                      }

                                      _undoTimer?.cancel();
                                      _undoTimer =
                                          Timer(const Duration(seconds: 5), () {
                                        _recentlyDeleted = null;
                                      });
                                    },
                                  );
                                },
                              ),
                  );
                },
              ),
            ),
    );
  }
}
