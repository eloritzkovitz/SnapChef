import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/theme/colors.dart';

class UpcomingAlertsScreen extends StatelessWidget {
  const UpcomingAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filterType = ValueNotifier<ReminderType?>(null);

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

            return ValueListenableBuilder<ReminderType?>(
              valueListenable: filterType,
              builder: (context, selectedType, _) {
                // Filter notifications based on dropdown
                final filtered = selectedType == null
                    ? viewModel.notifications
                    : viewModel.notifications
                        .where((n) =>
                            n is IngredientReminder && n.type == selectedType)
                        .toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Text('Show:'),
                          const SizedBox(width: 8),
                          DropdownButton<ReminderType?>(
                            value: selectedType,
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: ReminderType.expiry,
                                child: Text('Expiry'),
                              ),
                              DropdownMenuItem(
                                value: ReminderType.grocery,
                                child: Text('Grocery'),
                              ),
                            ],
                            onChanged: (type) => filterType.value = type,
                          ),
                        ],
                      ),
                    ),
                    if (filtered.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('No upcoming alerts.'),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final notification = filtered[index];
                            final isExpiry =
                                notification is IngredientReminder &&
                                    notification.type == ReminderType.expiry;
                            final isGrocery =
                                notification is IngredientReminder &&
                                    notification.type == ReminderType.grocery;

                            return ListTile(
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: isExpiry
                                        ? const Icon(Icons.schedule,
                                            color: Colors.orange, size: 32)
                                        : const Icon(Icons.shopping_cart,
                                            color: Colors.green, size: 32),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notification is IngredientReminder
                                                ? notification.ingredientName
                                                : notification.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (isExpiry)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Chip(
                                              label: Text('Expiry',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              backgroundColor: primaryColor,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                        if (isGrocery)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Chip(
                                              label: const Text('Grocery',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              backgroundColor:
                                                  primarySwatch[200],
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Scheduled for: ${DateFormat.yMMMd().add_jm().format(notification.scheduledTime.toLocal())}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editNotification(
                                          context, notification, viewModel);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDelete(
                                          context, notification.id, viewModel);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _editNotification(BuildContext context, AppNotification notification,
      NotificationsViewModel viewModel) {
    final TextEditingController ingredientNameController =
        TextEditingController(text: notification.title);
    final TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(notification.scheduledTime));
    final TextEditingController timeController = TextEditingController(
        text: DateFormat('HH:mm').format(notification.scheduledTime));
    final TextEditingController bodyController =
        TextEditingController(text: notification.body);

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

                  final updatedNotification = IngredientReminder(
                    id: notification.id,
                    ingredientName: ingredientNameController.text.trim(),
                    title: ingredientNameController.text.trim(),
                    body: bodyController.text.trim(),
                    scheduledTime: newScheduledTime,
                    type: notification is IngredientReminder
                        ? notification.type
                        : ReminderType.expiry,
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
