import 'package:flutter/material.dart';

/// Handles local notifications for note reminders.
/// Requires flutter_local_notifications and timezone packages when fully implemented.
class NotificationService {
  NotificationService._();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('Notification service initialized');
  }

  /// Request notification permissions (iOS & Android 13+)
  static Future<bool> requestPermissions() async {
    return true;
  }

  /// Schedule a reminder notification for a note
  static Future<void> scheduleReminder({
    required int noteId,
    required String noteTitle,
    required String notePreview,
    required DateTime scheduledTime,
  }) async {
    await cancelReminder(noteId);
    debugPrint('Reminder scheduled for note $noteId at $scheduledTime');
  }

  /// Cancel a scheduled reminder
  static Future<void> cancelReminder(int noteId) async {
    debugPrint('Reminder cancelled for note $noteId');
  }

  /// Cancel all reminders
  static Future<void> cancelAllReminders() async {
    debugPrint('All reminders cancelled');
  }

  /// Get pending notifications
  static Future<List<PendingNotification>> getPendingReminders() async {
    return [];
  }

  /// Handle notification tap
  static void _onNotificationTapped(dynamic response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show an immediate notification (for testing)
  static Future<void> showTestNotification() async {
    debugPrint('Test notification sent');
  }
}

/// Model for pending notifications
class PendingNotification {
  final int id;
  final String title;
  final String body;

  PendingNotification({
    required this.id,
    required this.title,
    required this.body,
  });
}

/// Dialog for picking reminder date and time
class ReminderPickerDialog extends StatefulWidget {
  final DateTime? initialDateTime;

  const ReminderPickerDialog({
    Key? key,
    this.initialDateTime,
  }) : super(key: key);

  @override
  State<ReminderPickerDialog> createState() => _ReminderPickerDialogState();
}

class _ReminderPickerDialogState extends State<ReminderPickerDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateTime ?? DateTime.now().add(const Duration(hours: 1));
    _selectedDate = initial;
    _selectedTime = TimeOfDay.fromDateTime(initial);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.alarm, color: Color(0xFFC39E18)),
          SizedBox(width: 10),
          Text('Set Reminder'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time'),
            subtitle: Text(_selectedTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickOption('1 hour', const Duration(hours: 1)),
              _buildQuickOption('Tomorrow', const Duration(days: 1)),
              _buildQuickOption('1 week', const Duration(days: 7)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final reminderDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            Navigator.pop(context, reminderDateTime);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC39E18),
            foregroundColor: Colors.white,
          ),
          child: const Text('Set Reminder'),
        ),
      ],
    );
  }

  Widget _buildQuickOption(String label, Duration duration) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        final newDate = DateTime.now().add(duration);
        setState(() {
          _selectedDate = newDate;
          _selectedTime = TimeOfDay.fromDateTime(newDate);
        });
      },
    );
  }
}
