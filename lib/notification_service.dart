import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'alarm_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  int _getValidNotificationId(int id) {
    // Map alarm id to a valid 32-bit signed integer value
    return id % 2147483647; // Max positive 32-bit integer
  }

  Future<void> scheduleAlarmNotification(Alarm alarm) async {
    if (!alarm.enabled) return;

    final scheduledDate = tz.TZDateTime.from(alarm.dateTime, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel_${_getValidNotificationId(alarm.id)}',
      'Alarm Channel',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
          alarm.sound.split('/').last.replaceAll('.mp3', '')),
      enableVibration: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    if (alarm.recurring == RecurringType.daily) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _getValidNotificationId(alarm.id),
        alarm.label.isNotEmpty ? alarm.label : 'Alarm',
        'Daily alarm at ${alarm.dateTime.hour}:${alarm.dateTime.minute}',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (alarm.recurring == RecurringType.weekdays) {
      final weekdays = [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      ];
      for (var day in weekdays) {
        final nextScheduled =
        _nextInstanceOfWeekdayTime(day, alarm.dateTime.hour, alarm.dateTime.minute);
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          _getValidNotificationId(alarm.id * 10 + day),
          alarm.label.isNotEmpty ? alarm.label : 'Alarm',
          'Weekday alarm at ${alarm.dateTime.hour}:${alarm.dateTime.minute}',
          nextScheduled,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } else {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _getValidNotificationId(alarm.id),
        alarm.label.isNotEmpty ? alarm.label : 'Alarm',
        'Alarm scheduled for ${alarm.dateTime.toLocal()}',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    var now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(_getValidNotificationId(id));
    for (int day = DateTime.monday; day <= DateTime.friday; day++) {
      await _flutterLocalNotificationsPlugin.cancel(_getValidNotificationId(id * 10 + day));
    }
  }
}
