import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  Future<void> _addInventory() async {
    final name = _nameController.text.trim();
    final category = _selectedCategory;
    final quantity = int.tryParse(_quantityController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final purchasePrice = double.tryParse(_purchasePriceController.text.trim());
    final description = _descriptionController.text.trim();

    if (name.isEmpty ||
        category == null ||
        quantity == null ||
        price == null ||
        purchasePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // final url = Uri.parse(
      //   'http://10.0.2.2:8000/api/inventory/',
      // ); // For Android Emulator

      final url = Uri.parse('http://192.168.1.113:8000/api/inventory/');

      // final url = Uri.parse(
      //   'https://3700-196-189-56-201.ngrok-free.app/api/inventory/',
      // ); //Ngrok

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (!mounted) return;

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login required')));
        return;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_name': name,
          'category': category.toLowerCase(),
          'quantity_in_stock': quantity,
          'price_per_unit': price,
          'purchase_price': purchasePrice,
          'product_description': description.isNotEmpty ? description : '',
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        _nameController.clear();
        _quantityController.clear();
        _priceController.clear();
        _purchasePriceController.clear();
        _descriptionController.clear();
        setState(() => _selectedCategory = null);
      } else {
        final error = jsonDecode(response.body);
        String message;

        if (error is Map) {
          message =
              error.values.first is List
                  ? error.values.first.first.toString()
                  : error.values.first.toString();
        } else {
          message = 'An error occurred';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.cyan.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Inventory",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput("Product Name", _nameController),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.cyan.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                items:
                    ['Foods', 'Drinks', 'Accessories']
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedCategory = value!),
              ),
            ),
            _buildInput(
              "Quantity",
              _quantityController,
              inputType: TextInputType.number,
            ),
            _buildInput(
              "Selling Price",
              _priceController,
              inputType: TextInputType.number,
            ),
            _buildInput(
              "Purchase Price",
              _purchasePriceController,
              inputType: TextInputType.number,
            ),
            _buildInput("Description", _descriptionController),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addInventory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Add Item",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
