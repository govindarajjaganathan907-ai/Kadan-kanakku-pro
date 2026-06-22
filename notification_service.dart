import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

/// Schedules and shows local notifications, e.g.
/// "Today's interest ₹1600 added for customer Ravi"
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  /// Show an immediate notification (used after the daily interest job runs).
  static Future<void> showInterestAddedNotification({
    required String customerName,
    required double interestAmount,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_interest_channel',
      'Daily Interest Updates',
      channelDescription: 'Notifies when daily interest is added to a loan',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Interest Added',
      "Today's interest ₹${interestAmount.toStringAsFixed(0)} added for $customerName",
      details,
    );
  }

  /// Schedule a recurring daily reminder at a fixed local time (e.g. 9:00 AM)
  /// to prompt the lender to review today's interest collections.
  static Future<void> scheduleDailyReminder({
    int hour = 9,
    int minute = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Daily reminder to review loan interest',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      1001,
      'Kadan Kanakku Pro',
      'Check today\'s interest updates for all active loans.',
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
