import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _shopList = [];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {}; // 👈 добавили

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  void _loadShopData() async {
    final data = await _storage.loadJson('shopping.json', {
      "1": {"item": "", "done": false},
    });

    setState(() {
      _shopList = data.entries
          .map(
            (e) => {
              "id": e.key,
              "item": e.value['item'] ?? "",
              "done": e.value['done'] ?? false,
            },
          )
          .toList();
    });
  }

  void _saveData() async {
    Map<String, dynamic> dataToSave = {};
    for (var i = 0; i < _shopList.length; i++) {
      dataToSave[(i + 1).toString()] = {
        "item": _shopList[i]['item'],
        "done": _shopList[i]['done'],
      };
    }
    await _storage.saveJson('shopping.json', dataToSave);
  }

  void _manualSave() {
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saved!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addItem() {
    final String newId = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      _controllers[newId] = TextEditingController();
      _focusNodes[newId] = FocusNode();

      _shopList.add({
        "id": newId,
        "item": "",
        "done": false,
        "isNew": true,
      });
    });

    _saveData();

    // 👇 Даем время UI обновиться и ставим фокус
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_focusNodes[newId]);
    });
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SHOPPING LIST"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 28),
            onPressed: _manualSave,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.8),
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: _addItem,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text(
                "ADD PRODUCT",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: _shopList.isEmpty
                ? const Center(
                    child: Text(
                      "The shopping list is empty",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemCount: _shopList.length,
                    itemBuilder: (context, index) {
                      final item = _shopList[index];
                      final id = item['id'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: item['done'],
                            onChanged: (val) {
                              setState(() => item['done'] = val);
                              _saveData();
                            },
                          ),
                          title: TextField(
                            key: ValueKey(id),

                            controller: _controllers.putIfAbsent(
                              id,
                              () => TextEditingController(text: item['item']),
                            )..selection = TextSelection.collapsed(
                                offset: item['item'].length),

                            focusNode: _focusNodes.putIfAbsent(
                              id,
                              () => FocusNode(),
                            ),

                            autofocus: item['isNew'] ?? false,

                            style: TextStyle(
                              fontSize: 22,
                              decoration: item['done']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item['done']
                                  ? Colors.grey
                                  : Colors.white,
                            ),

                            decoration: const InputDecoration(
                              hintText: "Buy...",
                              border: InputBorder.none,
                            ),

                            onChanged: (val) {
                              item['item'] = val;
                              item['isNew'] = false;
                              _saveData();
                            },

                            textInputAction: TextInputAction.next,

                            onSubmitted: (_) => _addItem(),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => _shopList.removeAt(index));
                              _saveData();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



