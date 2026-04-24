import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final StorageService _storage = StorageService();
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }
  void _loadContacts() async {
    final data = await _storage.loadJson('contacts.json', {
      "1": {"name": "DAUGHTER", "phone": ""},
      "2": {"name": "SON", "phone": ""},
      "3": {"name": "DOCTOR", "phone": ""},
      "4": {"name": "NEIGHBOR", "phone": ""},
      "5": {"name": "SOCIAL WORKER", "phone": ""}, // Новый
      "6": {"name": "PHARMACY", "phone": ""},      // Новый
    });
    // ... остальной код маппинга без изменений
 
    setState(() {
      _contacts = data.entries.map((e) => {
        "id": e.key,
        "name": e.value['name'],
        "phone": e.value['phone']
      }).toList();
    });
  }

  // Фоновое автосохранение
  void _saveContacts() async {
    Map<String, dynamic> dataToSave = {};
    for (var c in _contacts) {
      dataToSave[c['id']] = {"name": c['name'], "phone": c['phone']};
    }
    await _storage.saveJson('contacts.json', dataToSave);
  }

  // Ручное сохранение для дискетки
  void _manualSave() {
    _saveContacts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Numbers saved!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QUICK CALLS"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Дискетка сверху для визуального контроля
          IconButton(
            icon: const Icon(Icons.save, size: 28),
            onPressed: _manualSave,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            color: Colors.blue.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Поле имени
                  TextField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    controller: TextEditingController(text: _contacts[index]['name']),
                    onChanged: (val) {
                      _contacts[index]['name'] = val;
                      _saveContacts(); // Автосохранение
                    },
                    decoration: const InputDecoration(
                      hintText: "Name",
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(color: Colors.blueGrey),
                  // Поле номера
                  TextField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                    keyboardType: TextInputType.phone,
                    controller: TextEditingController(text: _contacts[index]['phone']),
                    onChanged: (val) {
                      _contacts[index]['phone'] = val;
                      _saveContacts(); // Автосохранение
                    },
                    decoration: const InputDecoration(
                      hintText: "Phone Number",
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.8),
                    radius: 25,
                    child: IconButton(
                      icon: const Icon(Icons.phone_forwarded, color: Colors.white, size: 28),
                      onPressed: () => _makeCall(_contacts[index]['phone']),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



