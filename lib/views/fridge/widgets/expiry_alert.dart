import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snapchef/services/notification_service.dart';

class ExpiryAlertDialog extends StatefulWidget {
  final String ingredientName;
  final Function(DateTime) onSetAlert;

  const ExpiryAlertDialog({
    required this.ingredientName,
    required this.onSetAlert,
    super.key,
  });

  @override
  State<ExpiryAlertDialog> createState() => _ExpiryAlertDialogState();
}

class _ExpiryAlertDialogState extends State<ExpiryAlertDialog> {
  final TextEditingController _dateController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    // Initialize the date controller with today's date
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Expiry Notification for ${widget.ingredientName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date Input Field
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Enter Date (YYYY-MM-DD)',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.datetime,
            onChanged: (value) {
              // Optionally validate the date format here
            },
          ),
          // Time Picker
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text('Time: ${selectedTime.format(context)}'),
            onTap: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (pickedTime != null && pickedTime != selectedTime) {
                setState(() {
                  selectedTime = pickedTime;
                });
              }
            },
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
              // Parse the date from the text field
              final DateTime selectedDate =
                  DateFormat('yyyy-MM-dd').parse(_dateController.text);

              final DateTime alertDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              // Call the onSetAlert callback
              widget.onSetAlert(alertDateTime);

              // Send a test notification
              NotificationService().scheduleTestNotification();               
             
              // Schedule the notification
              await NotificationService().scheduleExpiryNotification(
                widget.ingredientName,
                alertDateTime,
              );

              // Notify the user that the notification has been scheduled
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notification scheduled for ${widget.ingredientName} at ${alertDateTime.toLocal()}',
                  ),
                ),
              );

              Navigator.pop(context);
            } catch (e) {
              // Show an error if the date format is invalid
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid date format. Please use YYYY-MM-DD.'),
                ),
              );
            }
          },
          child: const Text('Set Notification'),
        ),
      ],
    );
  }
}