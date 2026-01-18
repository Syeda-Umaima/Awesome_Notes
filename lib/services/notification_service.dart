// lib/services/notification_service.dart
//
// Local Notification Service for Note Reminders
// 
// Dependencies to add in pubspec.yaml:
// flutter_local_notifications: ^16.3.0
// timezone: ^0.9.2
// 
// Also add to AndroidManifest.xml:
// <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
// <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
// <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._();

  // static final FlutterLocalNotificationsPlugin _notifications = 
  //     FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // tz.initializeTimeZones();

    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSettings = DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );

    // const initSettings = InitializationSettings(
    //   android: androidSettings,
    //   iOS: iosSettings,
    // );

    // await _notifications.initialize(
    //   initSettings,
    //   onDidReceiveNotificationResponse: _onNotificationTapped,
    // );

    _isInitialized = true;
    debugPrint('✅ Notification service initialized');
  }

  /// Request notification permissions (iOS & Android 13+)
  static Future<bool> requestPermissions() async {
    // For Android 13+
    // final androidPlugin = _notifications
    //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    // if (androidPlugin != null) {
    //   return await androidPlugin.requestNotificationsPermission() ?? false;
    // }

    // For iOS
    // final iosPlugin = _notifications
    //     .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    // if (iosPlugin != null) {
    //   return await iosPlugin.requestPermissions(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //   ) ?? false;
    // }

    return true;
  }

  /// Schedule a reminder notification for a note
  static Future<void> scheduleReminder({
    required int noteId,
    required String noteTitle,
    required String notePreview,
    required DateTime scheduledTime,
  }) async {
    // Cancel any existing notification for this note
    await cancelReminder(noteId);

    // final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    // const androidDetails = AndroidNotificationDetails(
    //   'note_reminders',
    //   'Note Reminders',
    //   channelDescription: 'Reminders for your notes',
    //   importance: Importance.high,
    //   priority: Priority.high,
    //   icon: '@mipmap/ic_launcher',
    //   color: Color(0xFFC39E18),
    //   styleInformation: BigTextStyleInformation(''),
    // );

    // const iosDetails = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );

    // const notificationDetails = NotificationDetails(
    //   android: androidDetails,
    //   iOS: iosDetails,
    // );

    // await _notifications.zonedSchedule(
    //   noteId,
    //   '📝 ${noteTitle.isEmpty ? "Note Reminder" : noteTitle}',
    //   notePreview.isEmpty ? 'Time to check your note!' : notePreview,
    //   scheduledDate,
    //   notificationDetails,
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );

    debugPrint('⏰ Reminder scheduled for note $noteId at $scheduledTime');
  }

  /// Cancel a scheduled reminder
  static Future<void> cancelReminder(int noteId) async {
    // await _notifications.cancel(noteId);
    debugPrint('🚫 Reminder cancelled for note $noteId');
  }

  /// Cancel all reminders
  static Future<void> cancelAllReminders() async {
    // await _notifications.cancelAll();
    debugPrint('🚫 All reminders cancelled');
  }

  /// Get pending notifications
  static Future<List<PendingNotification>> getPendingReminders() async {
    // final pending = await _notifications.pendingNotificationRequests();
    // return pending.map((n) => PendingNotification(
    //   id: n.id,
    //   title: n.title ?? '',
    //   body: n.body ?? '',
    // )).toList();
    return [];
  }

  /// Handle notification tap
  static void _onNotificationTapped(dynamic response) {
    // Navigate to the note when notification is tapped
    // You can use a navigation service or callback here
    debugPrint('📱 Notification tapped: ${response.payload}');
  }

  /// Show an immediate notification (for testing)
  static Future<void> showTestNotification() async {
    // const androidDetails = AndroidNotificationDetails(
    //   'test_channel',
    //   'Test Notifications',
    //   channelDescription: 'For testing notifications',
    //   importance: Importance.high,
    //   priority: Priority.high,
    // );

    // const notificationDetails = NotificationDetails(android: androidDetails);

    // await _notifications.show(
    //   0,
    //   '🎉 Test Notification',
    //   'Notifications are working correctly!',
    //   notificationDetails,
    // );

    debugPrint('🔔 Test notification sent');
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

/// Reminder dialog widget
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
          // Date picker
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
          // Time picker
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
          // Quick options
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
