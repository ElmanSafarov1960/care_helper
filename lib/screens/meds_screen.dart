import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';
import '../constants.dart';

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  final StorageService _storage = StorageService();
  List<Medicine> _meds = [];

  // Карты для стабильного хранения контроллеров и фокусов (твой метод)
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _durationControllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _loadMeds();
  }

  // Очистка памяти при закрытии экрана
  @override
  void dispose() {
    for (var c in _nameControllers.values) c.dispose();
    for (var c in _durationControllers.values) c.dispose();
    for (var f in _focusNodes.values) f.dispose();
    super.dispose();
  }

  void _loadMeds() async {
    final data = await _storage.loadJson('meds.json', {});
    setState(() {
      _meds = data.entries
          .map((e) => Medicine.fromJson(e.key, e.value))
          .toList();
    });
  }

  Future<void> _saveAll({bool showSnackBar = true}) async {
    // 1. Очистка старых будильников
    for (var med in _meds) {
      for (int i = 0; i < 10; i++) {
        int idToRemove = (med.name.hashCode + i).abs() % 100000;
        await AlarmService.cancelAlarm(idToRemove);
      }
    }

    // 2. Сохранение в JSON
    Map<String, dynamic> dataToSave = {};
    for (var m in _meds) {
      dataToSave[m.id] = m.toJson();
    }
    await _storage.saveJson('meds.json', dataToSave);

    // 3. Планирование новых будильников
    for (var med in _meds) {
      for (int i = 0; i < med.times.length; i++) {
        int notifyId = (med.name.hashCode + i).abs() % 100000;
        final hm = med.times[i].split(':');
        int hour = int.parse(hm[0]);
        int minute = int.parse(hm[1]);

        final now = DateTime.now();
        var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        await AlarmService.setAlarm(notifyId, scheduledDate, med.melody);
      }
    }

    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Alarms updated successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _addItem() {
    final String newId = DateTime.now().millisecondsSinceEpoch.toString();
    
    setState(() {
      // Создаем объекты управления заранее
      _nameControllers[newId] = TextEditingController();
      _durationControllers[newId] = TextEditingController(text: "30"); // По умолчанию 30 дней
      _focusNodes[newId] = FocusNode();

      _meds.add(Medicine(
        id: newId,
        startDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        times: ['08:00'],
        melody: 'vivaldi_spring.mp3',
        isNew: true, // Флаг для захвата курсора
      ));
    });

    // Сохраняем структуру
    _saveAll(showSnackBar: false);

    // ПЕРЕНОС КУРСИВА (как в твоем SHOP)
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_focusNodes.containsKey(newId)) {
        FocusScope.of(context).requestFocus(_focusNodes[newId]);
      }
    });
  }

  Future<void> _pickDate(Medicine med) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        med.startDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      _saveAll(showSnackBar: false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MEDICINES"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 28),
            onPressed: () => _saveAll(showSnackBar: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ЭТА КНОПКА ОСТАЕТСЯ (Она всегда на виду)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: _addItem,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("ADD MEDICINE", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    // ТУТ КНОПКА УДАЛЕНА (Больше не дублируется)
                               
                    ..._meds.asMap().entries.map((entry) {
                      return _buildMedicineCard(entry.value, entry.key);
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Medicine med, int index) {
    final id = med.id;

    return Card(
      key: ValueKey(id),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: ValueKey("name_$id"),
                    focusNode: _focusNodes.putIfAbsent(id, () => FocusNode()),
                    controller: _nameControllers.putIfAbsent(id, () => TextEditingController(text: med.name))
                      ..selection = TextSelection.collapsed(offset: med.name.length),
                    autofocus: med.isNew ?? false,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: "Name of medicine",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      med.name = val;
                      med.isNew = false;
                      _saveAll(showSnackBar: false); // Автосохранение текста
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red, size: 30),
                  onPressed: () {
                    setState(() {
                      _meds.removeAt(index);
                      _nameControllers.remove(id);
                      _durationControllers.remove(id);
                      _focusNodes.remove(id);
                    });
                    _saveAll(showSnackBar: false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text("Time of taking:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...med.times.asMap().entries.map((timeEntry) {
                  int tIndex = timeEntry.key;
                  return InputChip(
                    label: Text(timeEntry.value, style: const TextStyle(fontSize: 16)),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                        initialEntryMode: TimePickerEntryMode.input,
                      );
                      if (picked != null) {
                        final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        setState(() => med.times[tIndex] = formattedTime);
                        _saveAll(showSnackBar: false);
                      }
                    },
                    onDeleted: med.times.length > 1 ? () {
                      setState(() => med.times.removeAt(tIndex));
                      _saveAll(showSnackBar: false);
                    } : null,
                  );
                }).toList(),
                ActionChip(
                  avatar: const Icon(Icons.add_circle_outline),
                  label: const Text("Add"),
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      initialEntryMode: TimePickerEntryMode.input,
                    );
                    if (picked != null) {
                      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      setState(() => med.times.add(formattedTime));
                      _saveAll(showSnackBar: false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(med.startDate),
                    onPressed: () => _pickDate(med),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    key: ValueKey("days_$id"),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Days", border: UnderlineInputBorder()),
                    controller: _durationControllers.putIfAbsent(id, () => TextEditingController(text: med.duration))
                      ..selection = TextSelection.collapsed(offset: med.duration.length),
                    onChanged: (val) {
                      med.duration = val;
                      _saveAll(showSnackBar: false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  const Text("Sound:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: med.melody,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: appMelodies.map((melody) {
                        return DropdownMenuItem<String>(
                          value: melody['file'],
                          child: Text(melody['name']!, style: const TextStyle(fontSize: 18)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          med.melody = val!;
                        });
                        _saveAll(showSnackBar: false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
