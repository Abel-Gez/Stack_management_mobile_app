import 'package:flutter/material.dart';
import 'package:msmes_app/screens/sales_report_screen.dart';
import 'package:msmes_app/screens/inventory_list_screen.dart';
import 'package:msmes_app/screens/calculator_screen.dart';
import 'package:msmes_app/screens/add_inventory_screen.dart';
import 'package:msmes_app/screens/settings_screen.dart';
import 'package:msmes_app/screens/dashboard_screen.dart'; // New Dashboard screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(), // 0: Dashboard
    const InventoryListScreen(), // 1: Inventory
    const AddInventoryScreen(), // 2: Add
    const SalesScreen(), // 3: Calculator
    const SalesReportScreen(), // 4: Settings
  ];

  final List<String> _titles = [
    'Dashboard',
    'Inventory',
    'Add Inventory',
    'Sales',
    'Report',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00CFE8),
        centerTitle: true,
        elevation: 0,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF00CFE8),
        elevation: 8,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Sale'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Report'),
        ],
      ),
    );
  }
}
