import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import 'package:snapchef/theme/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AlertListItem extends StatelessWidget {
  final IngredientReminder notification;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlertListItem({
    super.key,
    required this.notification,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiry = notification.typeEnum == ReminderType.expiry;
    final isGrocery = notification.typeEnum == ReminderType.grocery;

    return Card(
      color: Colors.white,   
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),           
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FaIcon(
                FontAwesomeIcons.appleAlt,
                color: primaryColor,
                size: 32,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      notification.ingredientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isExpiry)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Chip(
                        label: Text('Expiry', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.orange,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  if (isGrocery)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Chip(
                        label: Text('Grocery', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.deepOrange,
                        visualDensity: VisualDensity.compact,
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
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}