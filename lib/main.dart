import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'package:remind_me/screens/main_menu.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart'; 

@pragma('vm:entry-point')
void onAlarm(int id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  if (!prefs.containsKey('alarm_sound_$id')) return;

  final storage = StorageService();
  final Map<String, dynamic> medsData = await storage.loadJson('meds.json', {});
  
  if (medsData.isEmpty) {
    await prefs.remove('alarm_sound_$id');
    await prefs.remove('alarm_time_$id');
    return;
  }

  String? soundFile = prefs.getString('alarm_sound_$id');
  int? scheduledTimeMs = prefs.getInt('alarm_time_$id');
  if (scheduledTimeMs == null) return;

  final scheduledTime = DateTime.fromMillisecondsSinceEpoch(scheduledTimeMs);
  final now = DateTime.now();
  final difference = now.difference(scheduledTime).inMinutes.abs();

  // ПРОВЕРКА ВРЕМЕНИ (в пределах 2 минут)
  if (difference < 2) {
    
    // 1. ПОКАЗЫВАЕМ УВЕДОМЛЕНИЕ ВСЕГДА (даже если soundFile == "none")
    // Оно теперь вне условия проверки звука
    await NotificationService.showNotification(
      id: id,
      title: "Care Helper",
      body: "Time to take your medication",
    );

    // 2. ИГРАЕМ МУЗЫКУ, ТОЛЬКО ЕСЛИ ОНА ВЫБРАНА
    if (soundFile != null && soundFile != "none") {
      final player = AudioPlayer();
      try {
        await player.play(AssetSource('sounds/$soundFile'));
        await player.setVolume(1.0);
      } catch (e) {
        print("Error playing sound: $e");
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ФИКСИРУЕМ ОРИЕНТАЦИЮ
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Твои настройки Edge-to-Edge
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Или Brightness.light, зависит от темы
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await AndroidAlarmManager.initialize();

  // 3. Запрос разрешений
  await [
    Permission.notification,
    Permission.scheduleExactAlarm,
    Permission.ignoreBatteryOptimizations,
  ].request();

  await NotificationService.init();
  runApp(const RemindMeApp());
}

class RemindMeApp extends StatelessWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care Helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const MainMenu(),
    );
  }
}


