import 'package:flutter/material.dart';
import 'dart:io';
import 'meds_screen.dart';
import 'shop_screen.dart';
import 'call_screen.dart';
import 'todo_screen.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Используем Stack, чтобы наложить кнопки поверх фонового изображения
      body: Stack(
        children: [
          // 1. Фон (аналог Rectangle в Kivy)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/day_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Контент меню
          // ... внутри Stack в main_menu.dart ...
          SafeArea(
            child: SingleChildScrollView(
              // <-- Добавляем прокрутку здесь
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      "Care Helper",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3399FF),
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildMenuButton(
                      context,
                      "MEDS",
                      Colors.blue.withOpacity(0.02),
                    ), // 50% прозрачности
                    _buildMenuButton(
                      context,
                      "SHOP",
                      Colors.blue.withOpacity(0.02),
                    ), // Едва заметный
                    _buildMenuButton(
                      context,
                      "TODO",
                      Colors.blue.withOpacity(0.02),
                    ),
                    _buildMenuButton(
                      context,
                      "CALL",
                      Colors.blue.withOpacity(0.02),
                    ),

                    const SizedBox(
                      height: 20,
                    ), // Вместо Spacer() используй SizedBox
                    // Кнопка EXIT
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ),
                        onPressed: () => exit(0),
                        child: const Text("EXIT"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательный метод для создания кнопок (аналог цикла по кнопкам)
  Widget _buildMenuButton(BuildContext context, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            side: BorderSide(color: color.withOpacity(0.4)), // Легкая рамка
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Внутри метода _buildMenuButton в файле main_menu.dart:
          onPressed: () {
            if (text == "MEDS") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedsScreen()),
              );
            } else if (text == "SHOP") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopScreen()),
              );
            } else if (text == "TODO") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TodoScreen()),
              );
            } else if (text == "CALL") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CallScreen()),
              );
            }
          },
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
