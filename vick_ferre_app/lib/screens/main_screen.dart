import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'add_item_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
class MainScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  const MainScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
        HomeScreen(
          onNavigate: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        const ScanScreen(),
        const AddItemScreen(),
        const InventoryScreen(),
        const ReportsScreen(),
        ProfileScreen(
          isDarkMode: widget.themeMode == ThemeMode.dark,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6D00),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF6D00),
              child: const Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vick's Store", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Sistema de Inventario", style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFF6D00),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Escanear'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Añadir'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Inventario'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}