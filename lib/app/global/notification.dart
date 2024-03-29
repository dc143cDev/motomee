import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> setup() async {
    const iosInitSetting = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const initSettings = InitializationSettings(iOS: iosInitSetting);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    await configureLocalTimeZone();
  }

  Future<void> getNotification() async {
    NotificationDetails platFrom = NotificationDetails(
      iOS: DarwinNotificationDetails(
        badgeNumber: 1,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
        0, 'hello', 'test noti!', platFrom);
  }

  tz.TZDateTime configureLocalTimeZone() {
    tz.initializeTimeZones();
    // final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    tz.TZDateTime _now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      _now.year,
      _now.month,
      _now.day,
    );

    return scheduledDate;
  }

  tz.TZDateTime timeZoneSetting({
    required int hour,
    required int minute,
  }) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    tz.TZDateTime _now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, _now.year, _now.month, _now.day, hour, minute);

    return scheduledDate;
  }

  NotificationDetails _details = const NotificationDetails(
    android: AndroidNotificationDetails('alarm 1', '1번 푸시'),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  Future selectedDateAlarm(int hour, int minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'test Alarm',
      'hi',
      timeZoneSetting(hour: hour, minute: minute),
      _details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
