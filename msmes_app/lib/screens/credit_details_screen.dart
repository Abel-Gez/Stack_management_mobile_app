import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'sales_detail_screen.dart'; // Ensure you have this screen defined

class CreditDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> saleData;

  const CreditDetailsScreen({Key? key, required this.saleData})
    : super(key: key);

  @override
  State<CreditDetailsScreen> createState() => _CreditDetailsScreenState();
}

class _CreditDetailsScreenState extends State<CreditDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String customerName = '';
  String customerPhone = '';
  String notes = '';
  DateTime? dueDate;

  Future<void> _submitCreditDetails() async {
    if (!_formKey.currentState!.validate() || dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    _formKey.currentState!.save();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse(
      'http://10.0.2.2:8000/api/sales/${widget.saleData['id']}/',
    );

    final creditData = {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'due_date': dueDate!.toIso8601String().split('T')[0], // yyyy-mm-dd
      'notes': notes,
    };

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(creditData),
    );

    if (response.statusCode == 200) {
      final updatedSale = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Credit details saved successfully.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SaleSummaryScreen(saleData: updatedSale),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save credit details.")));
      print("Error: ${response.body}");
    }
  }

  Future<void> _pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selected != null) {
      setState(() => dueDate = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.saleData;

    return Scaffold(
      appBar: AppBar(title: Text('Credit Sale Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Sale Summary:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text('Product: ${sale['product_name']}'),
              Text('Quantity: ${sale['quantity_sold']}'),
              Text('Price: ${sale['sale_price']}'),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Customer Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => customerName = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Customer Phone'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => customerPhone = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
                onSaved: (value) => notes = value ?? '',
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  dueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${dueDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCreditDetails,
                child: Text('Save Credit Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
