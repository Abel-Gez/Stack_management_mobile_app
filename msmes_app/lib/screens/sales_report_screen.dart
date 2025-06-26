import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  Map<String, dynamic>? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://192.168.1.113:8000/api/sales/summary/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        summary = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print("Error fetching summary: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.green, Colors.blue, Colors.red, Colors.orange];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Sales Report'),
        backgroundColor: Colors.amber,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : summary == null
              ? const Center(child: Text("No summary available."))
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              buildMetric(
                                "🧾 Total Sales",
                                summary!['total_sales'].toString(),
                              ),
                              buildMetric(
                                "💰 Total Revenue",
                                "${summary!['total_revenue']} ETB",
                              ),
                              buildMetric(
                                "📦 Total Cost",
                                "${summary!['total_cost']} ETB",
                              ),
                              buildMetric(
                                "📈 Profit",
                                "${summary!['total_profit']} ETB",
                                isProfit: true,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Most Sold: ${summary!['most_sold_product']?['inventory_item__product_name'] ?? 'N/A'} "
                                "(${summary!['most_sold_product']?['total_qty'] ?? 0})",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Profit Breakdown",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: summary!['total_cost'] * 1.0,
                                title: 'Cost',
                                color: Colors.red[400],
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: summary!['total_profit'] * 1.0,
                                title: 'Profit',
                                color: Colors.green[400],
                                radius: 60,
                              ),
                            ],
                            sectionsSpace: 4,
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget buildMetric(String label, String value, {bool isProfit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isProfit ? Colors.green[700] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
