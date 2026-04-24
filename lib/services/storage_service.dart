import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  // Получаем путь к папке с данными приложения (аналог get_path в твоем коде)
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Создаем ссылку на конкретный файл
  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  // ЗАГРУЗКА (аналог load_json)
  Future<Map<String, dynamic>> loadJson(String filename, Map<String, dynamic> defaultValue) async {
    try {
      final file = await _localFile(filename);
      if (await file.exists()) {
        String contents = await file.readAsString();
        return json.decode(contents);
      }
      return defaultValue;
    } catch (e) {
      print("Loading error $filename: $e");
      return defaultValue;
    }
  }

  // СОХРАНЕНИЕ (аналог save_json)
  Future<void> saveJson(String filename, Map<String, dynamic> data) async {
    try {
      final file = await _localFile(filename);
      String rawJson = json.encode(data);
      await file.writeAsString(rawJson);
    } catch (e) {
      print("Saving error $filename: $e");
    }
  }
}