import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  List<dynamic> _inventory = [];
  List<dynamic> _filteredInventory = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // final url = Uri.parse('http://10.0.2.2:8000//api/inventory/');

    final url = Uri.parse(
      'http://192.168.1.113:8000/api/inventory/',
    ); //Physical device

    // final url = Uri.parse(
    //   'https://3700-196-189-56-201.ngrok-free.app/api/inventory/',
    // ); //Ngrok

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _inventory = data;
        _filteredInventory = data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _filterInventory(String query) {
    setState(() {
      _searchQuery = query;
      _filteredInventory =
          _inventory
              .where(
                (item) => item['product_name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _deleteItem(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // final url = Uri.parse('http://10.0.2.2:8000//api/inventory/$id/');

    final url = Uri.parse(
      'http://192.168.1.113:8000/api/inventory/$id/',
    ); //physical device

    // final url = Uri.parse(
    //   'https://3700-196-189-56-201.ngrok-free.app/api/inventory/',
    // ); //Ngrok

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      _fetchInventory();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Item deleted")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete item")));
    }
  }

  void _openDetailScreen(dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryDetailScreen(item: item),
      ),
    );
  }

  Widget _buildInventoryItem(dynamic item) {
    return GestureDetector(
      onTap: () => _openDetailScreen(item),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: Colors.cyan.shade400,
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage:
                item['image'] != null
                    ? NetworkImage(item['image'])
                    : const AssetImage('assets/default_item.png')
                        as ImageProvider,
          ),
          title: Text(
            item['product_name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Qty: ${item['quantity_in_stock']}",
                style: const TextStyle(color: Colors.white),
              ),
              if (item['description'] != null)
                Text(
                  "Desc: ${item['description']}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // TODO: Navigate to edit screen
                },
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _deleteItem(item['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchInventory,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              onChanged: _filterInventory,
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredInventory.isEmpty
                    ? const Center(child: Text("No items found"))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filteredInventory.length,
                      itemBuilder:
                          (context, index) =>
                              _buildInventoryItem(_filteredInventory[index]),
                    ),
          ),
        ],
      ),
    );
  }
}

// Detail Screen (basic version)
class InventoryDetailScreen extends StatelessWidget {
  final dynamic item;

  const InventoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Detail"),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (item['image'] != null)
              Image.network(item['image'], height: 200, fit: BoxFit.cover)
            else
              const Icon(
                Icons.image_not_supported,
                size: 100,
                color: Colors.grey,
              ),
            const SizedBox(height: 20),

            // Product Name
            Text(
              "Product Name: ${item['product_name']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Quantity
            Text(
              "Quantity in Stock: ${item['quantity_in_stock']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Description
            if (item['description'] != null)
              Text(
                "Description: ${item['description']}",
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),

            // Purchase Price
            if (item['purchase_price'] != null)
              Text(
                "Purchase Price: ${item['purchase_price']} ETB",
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),

            // Sell Price
            if (item['sell_price'] != null)
              Text(
                "Selling Price: ${item['sell_price']} ETB",
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
