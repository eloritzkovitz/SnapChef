import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/theme/colors.dart'; // Make sure this imports your primaryColor and secondaryColor

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
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);
    _timeController.text = DateFormat('HH:mm').format(now);
  }

  bool _validateTime(String value) {
    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(value)) return false;
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: secondaryColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Expiry Notification for ${widget.ingredientName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date Input Field (read-only, always uses themed picker)
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date (YYYY-MM-DD)',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _pickDate(context),
          ),
          // Time Input Field (keyboard only, restrict to HH:mm)
          TextField(
            controller: _timeController,
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d:]')),
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: const InputDecoration(
              labelText: 'Time (HH:mm)',
              prefixIcon: Icon(Icons.access_time),
              hintText: 'e.g. 14:30',
            ),
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
              // Parse date
              final dateText = _dateController.text.trim();
              final timeText = _timeController.text.trim();

              // Validate date
              if (dateText.isEmpty) throw FormatException();
              final DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(dateText);

              // Validate and parse time
              if (!_validateTime(timeText)) throw FormatException();
              final timeParts = timeText.split(':');
              final int hour = int.parse(timeParts[0]);
              final int minute = int.parse(timeParts[1]);

              final DateTime alertDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                hour,
                minute,
              );

              // Call the onSetAlert callback
              widget.onSetAlert(alertDateTime);

              final viewModel = Provider.of<NotificationsViewModel>(context, listen: false);
              final int newId = await viewModel.generateUniqueNotificationId();
              await viewModel.addNotification(
                IngredientReminder(
                  id: newId,
                  ingredientName: widget.ingredientName,
                  title: 'Expiry Reminder',
                  body: '${widget.ingredientName} is about to expire! Make sure to use it!',
                  scheduledTime: alertDateTime,
                  type: ReminderType.expiry,
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notification scheduled for ${widget.ingredientName} at ${alertDateTime.toLocal()}',
                  ),
                ),
              );

              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid date or time format. Please use YYYY-MM-DD and HH:mm.'),
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