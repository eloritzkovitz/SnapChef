import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/expiry_notification.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';

class UpcomingAlertsScreen extends StatelessWidget {
  const UpcomingAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upcoming Alerts',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Consumer<NotificationsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.notifications.isEmpty) {
              return const Center(
                child: Text('No upcoming alerts.'),
              );
            }

            return ListView.builder(
              itemCount: viewModel.notifications.length,
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                return ListTile(
                  title: Text('Expiry alert for ${notification.ingredientName}'),
                  subtitle: Text(
                    'Scheduled for: ${DateFormat.yMMMd().add_jm().format(notification.scheduledTime.toLocal())}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editNotification(context, notification, viewModel);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _confirmDelete(context, notification.id, viewModel);
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
    );
  }

  void _editNotification(BuildContext context, ExpiryNotification notification,
      NotificationsViewModel viewModel) {
    final TextEditingController ingredientNameController =
        TextEditingController(text: notification.ingredientName);
    final TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(notification.scheduledTime));
    final TextEditingController timeController = TextEditingController(
        text: DateFormat('HH:mm').format(notification.scheduledTime));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ingredientNameController,
                decoration: const InputDecoration(
                  labelText: 'Ingredient Name',
                  prefixIcon: Icon(Icons.food_bank),
                ),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (HH:mm)',
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final DateTime newDate = DateFormat('yyyy-MM-dd')
                      .parse(dateController.text.trim());
                  final List<String> timeParts =
                      timeController.text.trim().split(':');
                  final int hour = int.parse(timeParts[0]);
                  final int minute = int.parse(timeParts[1]);

                  final DateTime newScheduledTime = DateTime(
                    newDate.year,
                    newDate.month,
                    newDate.day,
                    hour,
                    minute,
                  );

                  final updatedNotification = ExpiryNotification(
                    id: notification.id,
                    ingredientName: ingredientNameController.text.trim(),
                    body: notification.body,
                    scheduledTime: newScheduledTime,
                  );

                  await viewModel.editNotification(
                      notification.id, updatedNotification);

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid date or time format.'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int notificationId,
      NotificationsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content:
              const Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                await viewModel.deleteNotification(notificationId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}