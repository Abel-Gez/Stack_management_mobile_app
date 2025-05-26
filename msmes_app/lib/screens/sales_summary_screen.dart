import 'package:flutter/material.dart';

class SaleSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> saleData;

  const SaleSummaryScreen({Key? key, required this.saleData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sale Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "✅ Sale Successful!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 16),
                _buildRow(
                  "Product Name",
                  saleData['product_details']['product_name'],
                ),
                _buildRow(
                  "Quantity Sold",
                  saleData['quantity_sold'].toString(),
                ),
                _buildRow("Payment Type", saleData['payment_type'].toString()),
                if (saleData['customer_name'] != null &&
                    saleData['customer_name'].isNotEmpty)
                  _buildRow("Customer Name", saleData['customer_name']),
                if (saleData['customer_phone'] != null &&
                    saleData['customer_phone'].isNotEmpty)
                  _buildRow("Customer Phone", saleData['customer_phone']),
                _buildRow("Sale Price", "${saleData['sale_price']} ETB"),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Go back to the sale screen
                    },
                    icon: Icon(Icons.arrow_back),
                    label: Text('Back to Sale'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
