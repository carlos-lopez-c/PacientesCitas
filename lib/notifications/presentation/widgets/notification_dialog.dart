import 'package:flutter/material.dart';
import 'package:paciente_citas_1/notifications/domain/entities/notification_entity.dart';

class NotificationDialog extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const NotificationDialog({
    super.key,
    required this.notification,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getNotificationIcon(),
                  color: _getNotificationColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification.body,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onTap!();
                    },
                    child: const Text('Ver detalles'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    final type = NotificationType.fromString(notification.type);
    switch (type) {
      case NotificationType.newAppointment:
        return Icons.event_available;
      case NotificationType.appointmentUpdated:
        return Icons.update;
      case NotificationType.appointmentCancelled:
        return Icons.event_busy;
      case NotificationType.appointmentReminder:
        return Icons.alarm;
      case NotificationType.statusChanged:
        return Icons.info;
    }
  }

  Color _getNotificationColor() {
    final type = NotificationType.fromString(notification.type);
    switch (type) {
      case NotificationType.newAppointment:
        return Colors.green;
      case NotificationType.appointmentUpdated:
        return Colors.blue;
      case NotificationType.appointmentCancelled:
        return Colors.red;
      case NotificationType.appointmentReminder:
        return Colors.orange;
      case NotificationType.statusChanged:
        return Colors.purple;
    }
  }

  static void show(
    BuildContext context, 
    NotificationEntity notification, {
    VoidCallback? onTap,
  }) {
    showDialog(
      context: context,
      builder: (context) => NotificationDialog(
        notification: notification,
        onTap: onTap,
      ),
    );
  }
}