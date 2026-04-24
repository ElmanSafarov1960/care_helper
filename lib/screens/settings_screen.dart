import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedMelody = "vivaldi_spring.mp3";

  // Список мелодий (как в твоем оригинале)
  final List<Map<String, String>> _melodies = [

    {"name": "NO MUSIC", "file": "none"},
    {"name": "Vivaldi", "file": "vivaldi_spring.mp3"},
    {"name": "Mozart", "file": "mozart_march.mp3"},
    {"name": "Sinatra", "file": "sinatra_way.mp3"},
    {"name": "Beethoven", "file": "fur_elise.mp3"},
    {"name": "Bach", "file": "bach_air.mp3"},
    {"name": "Debussy", "file": "clair_de_lune_remix.mp3"},
    {"name": "Grieg", "file": "alexguz_morning_piano.mp3"},
    {"name": "Chopin", "file": "chopin_prelude_remix.mp3"},
    {"name": "Leberch", "file": "leberch_sad.mp3"},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Важно закрыть плеер при выходе
    super.dispose();
  }

  void _loadSettings() async {
    final data = await _storage.loadJson('settings.json', {"melody": "vivaldi_spring.mp3"});
    setState(() {
      _selectedMelody = data['melody'];
    });
  }

  void _saveAndPlay(String fileName) async {
    setState(() {
      _selectedMelody = fileName;
    });
    // Сохраняем в JSON
    await _storage.saveJson('settings.json', {"melody": fileName});

    // Проверка звука
    if (fileName == "none") {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.stop();
      // Воспроизведение из папки assets/sounds/
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOUND SETTINGS")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "CHOOSE A ALERT TONE",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _melodies.length,
                itemBuilder: (context, index) {
                  final m = _melodies[index];
                  bool isSelected = _selectedMelody == m['file'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected 
                            ? Colors.green.withOpacity(0.6) 
                            : Colors.blue.withOpacity(0.1),
                        minimumSize: const Size(double.infinity, 70),
                        side: BorderSide(
                          color: isSelected ? Colors.green : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      onPressed: () => _saveAndPlay(m['file']!),
                      child: Text(
                        m['name']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Text(
              "The sound will automatically fade away after 15 seconds when an alarm occurs",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
