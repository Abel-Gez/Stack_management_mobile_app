import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msmes_app/screens/sales_detail_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Map<String, List<Map<String, dynamic>>> categorizedProducts = {};
  List<Map<String, dynamic>> cart = [];
  Map<int, int> quantityMap = {}; // Maps product ID to quantity
  String paymentType = 'cash';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://192.168.1.113:8000/api/inventory/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List products = jsonDecode(response.body);
      setState(() {
        categorizedProducts = {};
        for (var product in products) {
          final category = product['category'] ?? 'Uncategorized';
          if (!categorizedProducts.containsKey(category)) {
            categorizedProducts[category] = [];
          }
          categorizedProducts[category]!.add(product);
        }
      });
    } else {
      print("Error loading products: ${response.body}");
    }
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
      quantityMap[product['id']] = (quantityMap[product['id']] ?? 0) + 1;
    });
  }

  void increaseQuantity() {
    if (cart.isNotEmpty) {
      final lastProduct = cart.last;
      final id = lastProduct['id'];
      setState(() {
        quantityMap[id] = (quantityMap[id] ?? 1) + 1;
      });
    }
  }

  void decreaseQuantity() {
    if (cart.isNotEmpty) {
      final lastProduct = cart.last;
      final id = lastProduct['id'];
      setState(() {
        final currentQty = quantityMap[id] ?? 1;
        if (currentQty > 1) {
          quantityMap[id] = currentQty - 1;
        } else {
          cart.removeLast();
          quantityMap.remove(id);
        }
      });
    }
  }

  double calculateTotal() {
    double total = 0;
    for (var product in cart) {
      final qty = quantityMap[product['id']] ?? 1;
      final price = double.tryParse(product['price_per_unit'].toString()) ?? 0;
      total += qty * price;
    }
    return total;
  }

  Future<void> submitSale() async {
    if (cart.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() => isLoading = true);

    Map<String, dynamic>? lastSaleResponse;

    for (var product in cart.toSet()) {
      final id = product['id'];
      final saleData = {
        'product_name': id,
        'quantity_sold': quantityMap[id] ?? 1,
        'sale_price': product['price_per_unit'],
        'payment_type': paymentType,
      };

      final response = await http.post(
        Uri.parse('http://192.168.1.113:8000/api/sales/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(saleData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        lastSaleResponse = jsonDecode(response.body);
        lastSaleResponse?['product_details'] = product;
      } else {
        print("Error: ${response.body}");
      }
    }

    setState(() {
      cart.clear();
      quantityMap.clear();
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sale submitted successfully.")),
    );

    if (lastSaleResponse != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SaleSummaryScreen(saleData: lastSaleResponse!),
        ),
      );
    }

    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final categoryList = categorizedProducts.keys.toList();
    final functionButtons = ['+', '-', 'CLEAR', 'SALE'];

    final totalRows = 4;
    final paddedLabels = List.generate(totalRows * 3, (i) {
      return i < categoryList.length ? categoryList[i] : '';
    });

    final gridButtons = <Map<String, dynamic>>[];
    for (int i = 0; i < totalRows; i++) {
      gridButtons.addAll([
        {'label': paddedLabels[i * 3], 'type': 'category'},
        {'label': paddedLabels[i * 3 + 1], 'type': 'category'},
        {'label': paddedLabels[i * 3 + 2], 'type': 'category'},
        {'label': functionButtons[i], 'type': 'function'},
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: Colors.amber[700],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cart.isEmpty
                      ? '🧾 No items selected.'
                      : cart
                          .map(
                            (e) =>
                                '${e['product_name']} x${quantityMap[e['id']] ?? 1}',
                          )
                          .join(', '),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total: ${calculateTotal().toStringAsFixed(2)} Birr',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: paymentType,
                  onChanged: (val) {
                    if (val != null) setState(() => paymentType = val);
                  },
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'credit', child: Text('Credit')),
                    DropdownMenuItem(
                      value: 'mobile',
                      child: Text('Mobile Payment'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: gridButtons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final btn = gridButtons[index];
                  final label = btn['label'];
                  final type = btn['type'];

                  if (label == '') return const SizedBox.shrink();

                  Color? bgColor;
                  if (type == 'function') {
                    if (label == 'CLEAR') {
                      bgColor = Colors.red[300];
                    } else if (label == 'SALE') {
                      bgColor = Colors.yellow[600];
                    } else {
                      bgColor = Colors.grey[300];
                    }
                  } else {
                    bgColor = Colors.orange[200];
                  }

                  return ElevatedButton(
                    onPressed: () {
                      if (type == 'category') {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder:
                              (_) => ItemPopup(
                                category: label,
                                items: categorizedProducts[label]!,
                                onItemSelected: addToCart,
                              ),
                        );
                      } else {
                        if (label == '+') {
                          increaseQuantity();
                        } else if (label == '-') {
                          decreaseQuantity();
                        } else if (label == 'CLEAR') {
                          setState(() {
                            cart.clear();
                            quantityMap.clear();
                          });
                        } else if (label == 'SALE') {
                          submitSale();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemPopup extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onItemSelected;

  const ItemPopup({
    super.key,
    required this.category,
    required this.items,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$category Items",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children:
                  items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onItemSelected(item);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.amber[100],
                            radius: 30,
                            child: const Icon(
                              Icons.shopping_bag,
                              size: 30,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['product_name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
