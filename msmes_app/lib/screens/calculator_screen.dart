import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'sales_summary_screen.dart';
import 'credit_details_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<dynamic> products = [];
  dynamic selectedProduct;
  int quantity = 1;
  String paymentType = 'cash';
  String customerName = '';
  String customerPhone = '';

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/inventory/'), // Android Emulator
      headers: {'Authorization': 'Bearer $token'},
    );

    // final response = await http.get(
    //   Uri.parse('http://192.168.1.113:8000/api/inventory/'), // physical device
    //   headers: {'Authorization': 'Bearer $token'},
    // );

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      print("Error loading products: ${response.body}");
    }
  }

  Future<void> submitSale() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (!_formKey.currentState!.validate() || selectedProduct == null) return;

    setState(() => isLoading = true);

    final saleData = {
      'product_name': selectedProduct!['id'],
      'quantity_sold': quantity,
      'sale_price': selectedProduct!['price_per_unit'],
      'payment_type': paymentType,
      // Do NOT include customer fields here
    };

    print("Sending sale data: ${jsonEncode(saleData)}");

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/sales/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(saleData),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      final saleResponse = jsonDecode(response.body);

      if (paymentType == 'credit') {
        // Navigate to CreditDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditDetailsScreen(saleData: saleResponse),
          ),
        );
      } else {
        // Navigate to SaleSummaryScreen (for cash)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Sale recorded successfully.")));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleSummaryScreen(saleData: saleResponse),
          ),
        );
      }

      // Reset form
      setState(() {
        selectedProduct = null;
        quantity = 1;
        paymentType = 'cash';
        customerName = '';
        customerPhone = '';
      });

      fetchProducts(); // refresh inventory
    } else {
      print("Sale failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sale failed. ${response.statusCode}.")),
      );
      throw Exception("Sale failed. Server says: ${response.body}");
    }
  }

  // Future<void> submitSale() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('auth_token');
  //   if (!_formKey.currentState!.validate() || selectedProduct == null) return;

  //   if (paymentType == 'credit') {
  //     // Require name and phone for credit sales
  //     if (customerName.trim().isEmpty || customerPhone.trim().isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Customer name and phone are required for credit sales.',
  //           ),
  //         ),
  //       );
  //       return;
  //     }
  //   }

  //   setState(() => isLoading = true);

  //   final saleData = {
  //     'product_name': selectedProduct!['id'],
  //     'quantity_sold': quantity,
  //     'sale_price': selectedProduct!['price_per_unit'],
  //     'payment_type': paymentType,
  //     'customer_name': customerName,
  //     'customer_phone': customerPhone,
  //   };

  //   print("Sending sale data: ${jsonEncode(saleData)}");

  //   final response = await http.post(
  //     Uri.parse('http://10.0.2.2:8000/api/sales/'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //     body: jsonEncode(saleData),
  //   );

  //   setState(() => isLoading = false);

  //   if (response.statusCode == 201) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Sale recorded successfully.")));

  //     setState(() {
  //       selectedProduct = null;
  //       quantity = 1;
  //       paymentType = 'cash';
  //       customerName = '';
  //       customerPhone = '';
  //     });

  //     fetchProducts(); // refresh inventory

  //     final saleResponse = jsonDecode(response.body);

  //     // Go to SaleSummaryScreen or CreditDetailsScreen
  //     if (paymentType == 'credit') {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => CreditDetailsScreen(saleData: saleResponse),
  //         ),
  //       );
  //     } else {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => SaleSummaryScreen(saleData: saleResponse),
  //         ),
  //       );
  //     }
  //   } else {
  //     print("Sale failed: ${response.body}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Sale failed. ${response.statusCode}.")),
  //     );
  //     throw Exception("Sale failed. Server says: ${response.body}");
  //   }
  // }

  // Future<void> submitSale() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('auth_token');
  //   if (!_formKey.currentState!.validate() || selectedProduct == null) return;

  //   setState(() => isLoading = true);

  //   // print("Sending sale data: ${jsonEncode(selectedProduct)}");
  //   print(
  //     "Sending sale data: ${jsonEncode({'product_name': selectedProduct['id'], 'quantity_sold': quantity, 'payment_type': paymentType, 'customer_name': customerName, 'customer_phone': customerPhone})}",
  //   );

  //   final response = await http.post(
  //     Uri.parse('http://10.0.2.2:8000/api/sales/'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },

  //     // final response = await http.post(
  //     //   Uri.parse('http://192.168.1.113:8000/api/sales/'),
  //     //   headers: {
  //     //     'Content-Type': 'application/json',
  //     //     'Authorization': 'Bearer $token',
  //     //   },
  //     body: jsonEncode({
  //       'product_name': selectedProduct['id'],
  //       'quantity_sold': quantity,
  //       'sale_price': selectedProduct['price_per_unit'],
  //       'payment_type': paymentType,
  //       'customer_name': customerName,
  //       'customer_phone': customerPhone,
  //     }),
  //   );

  //   setState(() => isLoading = false);

  //   if (response.statusCode == 201) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Sale recorded successfully.")));

  //     setState(() {
  //       selectedProduct = null;
  //       quantity = 1;
  //       paymentType = 'cash';
  //       customerName = '';
  //       customerPhone = '';
  //     });

  //     fetchProducts(); // refresh inventory

  //     final saleResponse = jsonDecode(response.body);
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => SaleSummaryScreen(saleData: saleResponse),
  //       ),
  //     );
  //   } else {
  //     print("Sale failed: ${response.body}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Sale failed. ${response.statusCode}.")),
  //     );
  //     throw Exception("Sale failed. Server says: ${response.body}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Sale')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value:
                            selectedProduct != null &&
                                    products.any(
                                      (product) =>
                                          product['id'] ==
                                          selectedProduct['id'],
                                    )
                                ? selectedProduct
                                : null,
                        items:
                            products.map<
                              DropdownMenuItem<Map<String, dynamic>>
                            >((item) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: item,
                                child: Text(
                                  "${item['product_name']} - ${item['quantity_in_stock']} pcs",
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProduct = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select Product",
                        ),
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a product'
                                    : null,
                      ),

                      TextFormField(
                        decoration: InputDecoration(labelText: "Quantity"),
                        initialValue: "1",
                        keyboardType: TextInputType.number,
                        onChanged: (val) => quantity = int.tryParse(val) ?? 1,
                        validator:
                            (val) =>
                                val == null || int.tryParse(val)! <= 0
                                    ? "Enter valid quantity"
                                    : null,
                      ),
                      DropdownButtonFormField(
                        value: paymentType,
                        items: [
                          DropdownMenuItem(value: 'cash', child: Text("Cash")),
                          DropdownMenuItem(
                            value: 'credit',
                            child: Text("Credit"),
                          ),
                          DropdownMenuItem(
                            value: 'mobile',
                            child: Text("Mobile Payment"),
                          ),
                        ],
                        onChanged: (val) => setState(() => paymentType = val!),
                        decoration: InputDecoration(labelText: "Payment Type"),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: submitSale,
                        child: Text("Submit Sale"),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
