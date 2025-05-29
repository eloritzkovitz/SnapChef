import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import '../../../models/ingredient.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';
import 'package:snapchef/theme/colors.dart';

class IngredientReminderDialog extends StatefulWidget {
  final Ingredient ingredient;
  final ReminderType type;
  final Function(DateTime) onSetAlert;

  const IngredientReminderDialog({
    required this.ingredient,
    required this.type,
    required this.onSetAlert,
    super.key,
  });

  @override
  State<IngredientReminderDialog> createState() => _IngredientReminderState();
}

class _IngredientReminderState extends State<IngredientReminderDialog> {
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: secondaryColor,
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
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: secondaryColor,
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
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
        dialogTheme: DialogThemeData(backgroundColor: Colors.white),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            widget.type == ReminderType.expiry
                ? 'Set Expiry Reminder'
                : 'Set Grocery Reminder',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.ingredient.imageURL.isNotEmpty
                          ? widget.ingredient.imageURL
                          : 'assets/images/placeholder_image.png',
                    ),
                    fit: BoxFit.contain,
                    onError: (exception, stackTrace) {},
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: null,
              ),
              const SizedBox(height: 12),
              Text(
                widget.ingredient.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Icon(Icons.calendar_today, color: primaryColor),
                label: Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDateTime),
                  style: TextStyle(color: primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _pickDate(context),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: Icon(Icons.access_time, color: primaryColor),
                label: Text(
                  DateFormat('HH:mm').format(_selectedDateTime),
                  style: TextStyle(color: primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _pickTime(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final alertDateTime = _selectedDateTime;

                widget.onSetAlert(alertDateTime);

                final viewModel =
                    Provider.of<NotificationsViewModel>(context, listen: false);
                final userViewModel =
                    Provider.of<UserViewModel>(context, listen: false);
                final String newId =
                    await viewModel.generateUniqueNotificationId();
                await viewModel.addNotification(
                  IngredientReminder(
                    id: newId,
                    ingredientName: widget.ingredient.name,
                    title: widget.type == ReminderType.expiry
                        ? 'Expiry Reminder'
                        : 'Grocery Reminder',
                    body: widget.type == ReminderType.expiry
                        ? '${widget.ingredient.name} is about to expire! Make sure to use it!'
                        : '${widget.ingredient.name} is on your grocery list!',
                    scheduledTime: alertDateTime,
                    typeEnum: widget.type,
                    recipientId: userViewModel.user?.id ?? '',
                  ),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Notification scheduled for ${widget.ingredient.name} at ${alertDateTime.toLocal()}',
                      ),
                    ),
                  );
                }

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
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }
}
