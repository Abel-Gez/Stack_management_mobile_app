import 'package:flutter/material.dart';
import 'inventory_list_screen.dart';
import 'calculator_screen.dart';
import 'add_inventory_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InventoryListScreen(),
    const AddInventoryScreen(),
    const CalculatorScreen(),
    const SettingsScreen(),
  ];

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const SizedBox(
          height: 200,
          child: Center(child: Text("More options coming soon...")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00CFE8),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openMoreMenu,
        backgroundColor: const Color(0xFF3A86FF),
        child: const Icon(Icons.more_horiz),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFB2F5F0),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFB2F5F0),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF3A86FF),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
            BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calc'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
