import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Используем одно имя переменной везде
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
      'care_helper_urgent_v4', // МЕНЯЕМ ID на v4, чтобы сбросить старые настройки системы
      'Urgent Reminders',
      channelDescription: 'Notifications for medical procedures',
      importance: Importance.max, // Обязательно для всплывающего баннера
      priority: Priority.high,    // Обязательно для баннера
      fullScreenIntent: true,     // Позволяет всплыть на заблокированном экране
      category: AndroidNotificationCategory.reminder,
      playSound: true,
      enableVibration: true,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _notifications.show(id, title, body, platformDetails);
  }
}


