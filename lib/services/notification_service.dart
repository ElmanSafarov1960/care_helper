import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    // Убедись, что локация совпадает с системной
    tz.setLocalLocation(tz.getLocation('Europe/Kiev'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notifications.initialize(
      const InitializationSettings(android: initializationSettingsAndroid),
    );
  }
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_silent_v1', // Новый ID канала, чтобы сбросить старые настройки
      'Medicine Reminders',
      importance: Importance.max,
      priority: Priority.max,
      playSound: false, // ГОВОРИМ СИСТЕМЕ: НЕ ИГРАЙ СВОЙ ЗВУК
      enableVibration: true,
      silent: true, // Дополнительный флаг тишины
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _notifications.show(id, title, body, platformDetails);
  }
}
 
