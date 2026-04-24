
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class AlarmService {
  static Future<void> setAlarm(int id, DateTime time, String soundFile) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Сохраняем звук и время планирования
    await prefs.setString('alarm_sound_$id', soundFile);
    await prefs.setInt('alarm_time_$id', time.millisecondsSinceEpoch);
    await prefs.reload();

    final CallbackHandle? handle = PluginUtilities.getCallbackHandle(onAlarm);
    
    if (handle != null) {
      await AndroidAlarmManager.oneShotAt(
        time,
        id,
        onAlarm,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );
    }
  }

  // ДОБАВЬ ЭТОТ МЕТОД:
  static Future<void> cancelAlarm(int id) async {
    // 1. Отменяем будильник в системе Android
    await AndroidAlarmManager.cancel(id);
    
    // 2. Чистим данные из памяти SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alarm_sound_$id');
    await prefs.remove('alarm_time_$id');
    
    print("DEBUG: Alarm with ID $id cancelled and deleted from memory");
  }
}
