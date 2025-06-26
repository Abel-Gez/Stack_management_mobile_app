import 'package:flutter/material.dart';
import 'package:msmes_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = '';
  String phone = '';
  int inventoryCount = 0;
  int salesCount = 0;
  int creditCount = 0;
  int suppliersCount = 0;

  final storage =
      FlutterSecureStorage(); // Make sure it's defined globally or passed properly

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchDashboardData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName =
          '${prefs.getString('first_name') ?? ''} ${prefs.getString('last_name') ?? ''}';
      phone = prefs.getString('phone') ?? '';
    });
  }

  Future<void> fetchDashboardData() async {
    try {
      final inventoryData = await ApiService.fetchAuthJson(
        '/api/inventory/count/',
      );
      final salesData = await ApiService.fetchAuthJson('/api/sales/count/');
      final creditData = await ApiService.fetchAuthJson('/api/credit/count/');
      final supplierData = await ApiService.fetchAuthJson(
        '/api/inventory/count/',
      ); // change if needed

      if (inventoryData != null &&
          salesData != null &&
          creditData != null &&
          supplierData != null) {
        setState(() {
          inventoryCount = inventoryData['count'];
          salesCount = salesData['count'];
          creditCount = creditData['count'];
          suppliersCount = supplierData['count'];
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(userName),
                subtitle: Text(phone),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String initials = '';
    if (userName.isNotEmpty) {
      final parts = userName.trim().split(' ');
      initials =
          parts
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase();
    }

    // String initials =
    //     userName.isNotEmpty
    //         ? userName
    //             .trim()
    //             .split(' ')
    //             .map((e) => e[0])
    //             .take(2)
    //             .join()
    //             .toUpperCase()
    //         : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00CFE8),
        elevation: 0,
        centerTitle: true,
        title: Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min, // Prevent overflow
            children: const [
              Icon(Icons.store, color: Colors.black),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'MSMES Dashboard',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: _showProfileModal,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  initials,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardTile(Icons.inventory_2, "Inventory", inventoryCount),
            _buildDashboardTile(Icons.shopping_cart, "Sales", salesCount),
            _buildDashboardTile(Icons.credit_card, "Credit", creditCount),
            _buildDashboardTile(
              Icons.supervised_user_circle,
              "Suppliers",
              suppliersCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(IconData icon, String label, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.cyan[700]),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
