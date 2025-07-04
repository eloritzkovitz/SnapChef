import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/notifications/widgets/alert_list_item.dart';
import 'package:snapchef/theme/colors.dart';

import '../../widgets/base_screen.dart';
import '../../widgets/snapchef_appbar.dart';

class UpcomingAlertsScreen extends StatelessWidget {  
  const UpcomingAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filterType = ValueNotifier<ReminderType?>(null);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final userId = userViewModel.user?.id;

    return BaseScreen(
      appBar: SnapChefAppBar(
        title: const Text('Upcoming Alerts',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Only show IngredientReminder for the current user
          final ingredientReminders = viewModel.alerts
              .where((n) =>
                  n is IngredientReminder &&
                  (userId == null || (n).recipientId == userId))
              .toList();

          return ValueListenableBuilder<ReminderType?>(
            valueListenable: filterType,
            builder: (context, selectedType, _) {
              // Filter notifications based on dropdown
              final filtered = selectedType == null
                  ? ingredientReminders
                  : ingredientReminders
                      .where((n) =>
                          n is IngredientReminder &&
                          n.typeEnum == selectedType)
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
                          final notification =
                              filtered[index] as IngredientReminder;
                          return AlertListItem(
                            notification: notification,
                            onEdit: () => _editNotification(
                                context, notification, viewModel),
                            onDelete: () => _confirmDelete(
                                context, notification.id, viewModel),
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
    );
  }

  void _editNotification(BuildContext context, AppNotification notification,
      NotificationsViewModel viewModel) {
    DateTime selectedDateTime = notification.scheduledTime;

    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  'Edit Reminder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ingredient icon (like create dialog)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: FaIcon(
                        FontAwesomeIcons.appleAlt,
                        color: primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification is IngredientReminder
                          ? notification.ingredientName
                          : notification.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    // Notification type chip
                    if (notification is IngredientReminder)
                      Chip(
                        label: Text(
                          notification.typeEnum == ReminderType.expiry
                              ? 'Expiry'
                              : 'Grocery',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            notification.typeEnum == ReminderType.expiry
                                ? Colors.orange
                                : Colors.deepOrange,
                        visualDensity: VisualDensity.compact,
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today, color: primaryColor),
                      label: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDateTime),
                        style: TextStyle(color: primaryColor),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: primaryColor,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: primaryColor,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              selectedDateTime.hour,
                              selectedDateTime.minute,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: Icon(Icons.access_time, color: primaryColor),
                      label: Text(
                        DateFormat('HH:mm').format(selectedDateTime),
                        style: TextStyle(color: primaryColor),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: primaryColor,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: primaryColor,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                          initialEntryMode: TimePickerEntryMode.input,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              selectedDateTime.year,
                              selectedDateTime.month,
                              selectedDateTime.day,
                              picked.hour,
                              picked.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    try {
                      final userViewModel =
                          Provider.of<UserViewModel>(context, listen: false);
                      final updatedNotification = IngredientReminder(
                        id: notification.id,
                        ingredientName: notification is IngredientReminder
                            ? notification.ingredientName
                            : notification.title,
                        title: notification is IngredientReminder
                            ? notification.ingredientName
                            : notification.title,
                        body: notification.body,
                        scheduledTime: selectedDateTime,
                        typeEnum: notification is IngredientReminder
                            ? (notification.type as ReminderType)
                            : ReminderType.expiry,
                        recipientId: userViewModel.user?.id ??
                            '', // Ensure recipientId is set
                      );

                      await viewModel.editNotification(
                          notification.id, updatedNotification);

                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid date or time format.'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String notificationId,
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
