import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationUtils {
  /// Initialize notification channels
  static Future<void> initializeNotificationChannels() async {
    await AwesomeNotifications().initialize(
      // Set the default app icon
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'task_channel',
          channelName: 'Task Reminders',
          channelDescription: 'Regular task reminder notifications',
          defaultColor: const Color(0xFF6750A4),
          ledColor: Colors.white,
          playSound: true,
          enableVibration: true,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'critical_channel',
          channelName: 'Critical Task Reminders',
          channelDescription: 'High priority task reminders that need immediate attention',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          playSound: true,
          enableVibration: true,
          vibrationPattern: highVibrationPattern,
          importance: NotificationImportance.Max,
        ),
      ],
    );
  }

  /// Request notification permissions
  static Future<bool> requestNotificationPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }
}
