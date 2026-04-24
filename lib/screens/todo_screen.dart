import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _tasks = [];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final data = await _storage.loadJson('todo.json', {"tasks": []});

    setState(() {
      _tasks = List<Map<String, dynamic>>.from(data["tasks"]);

      for (var task in _tasks) {
        final id = task['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        task['id'] = id;

        _controllers[id] =
            TextEditingController(text: task['title'] ?? '');
        _focusNodes[id] = FocusNode();
      }
    });
  }

  void _saveTasks() async {
    await _storage.saveJson('todo.json', {"tasks": _tasks});
  }

  void _manualSave() {
    _saveTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tasks saved!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addTask() {
    final String newId = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      _controllers[newId] = TextEditingController();
      _focusNodes[newId] = FocusNode();

      _tasks.add({
        "id": newId,
        "title": "",
        "done": false,
        "isNew": true,
      });
    });

    _saveTasks();

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
        title: const Text("TO-DO LIST"),
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
          // Кнопка добавления
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.8),
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: _addTask,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "ADD TASK",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text("The to-do list is empty",
                        style: TextStyle(fontSize: 20)))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, i) {
                      final task = _tasks[i];
                      final id = task['id'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Checkbox(
                            value: task["done"],
                            onChanged: (val) {
                              setState(() => task["done"] = val);
                              _saveTasks();
                            },
                          ),

                          title: TextField(
                            controller: _controllers.putIfAbsent(
                              id,
                              () => TextEditingController(
                                  text: task['title']),
                            )..selection = TextSelection.collapsed(
                                offset: (task['title'] ?? '').length),

                            focusNode: _focusNodes.putIfAbsent(
                              id,
                              () => FocusNode(),
                            ),

                            autofocus: task['isNew'] ?? false,

                            style: TextStyle(
                              fontSize: 22,
                              decoration: task["done"]
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task["done"]
                                  ? Colors.grey
                                  : Colors.white,
                            ),

                            decoration: const InputDecoration(
                              hintText: "Task...",
                              border: InputBorder.none,
                            ),

                            onChanged: (val) {
                              task['title'] = val;
                              task['isNew'] = false;
                              _saveTasks();
                            },

                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _addTask(),
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () {
                              setState(() => _tasks.removeAt(i));
                              _saveTasks();
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



