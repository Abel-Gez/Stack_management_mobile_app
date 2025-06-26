import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedPlan;
  bool _isLoading = false;
  String? _txRef;

  Future<void> _startPayment(String plan) async {
    if (_isLoading) return; // ✅ Prevent multiple taps

    setState(() {
      _isLoading = true;
      _selectedPlan = plan;
    });

    final token = await ApiService.getToken();
    final user = await ApiService.getUserProfile();

    final url = Uri.parse('${ApiService.baseUrl}/api/payments/initialize/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan': plan,
          'user_id': user['id'],
          'email': user['email'],
          'first_name': user['username'],
          'last_name': user['role'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _txRef = data['tx_ref'];

        if (plan == 'free') {
          // ✅ Free plan: no redirect, directly verify
          _showMessage('Free plan activated. Verifying...');

          final updatedProfile = await ApiService.getUserProfile();
          final status = updatedProfile['subscription_status'];

          if (!mounted) return;
          if (status == 'active') {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _showMessage('Subscription still inactive. Try again.');
          }
        } else {
          // ✅ Paid plan: open Chapa payment page
          final checkoutUrl = data['checkout_url'];
          if (checkoutUrl != null) {
            final launched = await launchUrl(
              Uri.parse(checkoutUrl),
              mode: LaunchMode.externalApplication,
            );
            if (launched) {
              _pollForConfirmation();
            } else {
              _showMessage('Could not open payment page.');
            }
          } else {
            _showMessage('Missing checkout URL from Chapa.');
          }
        }
      } else {
        _showMessage('Payment failed: ${data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showMessage('Error initializing payment: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pollForConfirmation() async {
    if (_txRef == null) return;

    setState(() => _isLoading = true); // Show spinner

    const pollInterval = Duration(seconds: 5);
    const maxAttempts = 20;
    int attempts = 0;

    try {
      while (attempts < maxAttempts) {
        await Future.delayed(pollInterval);

        if (!mounted) return;

        final token = await ApiService.getToken();
        final url = Uri.parse(
          '${ApiService.baseUrl}/api/payments/status/$_txRef/',
        );

        final res = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'confirmed') {
            _showMessage('✅ Subscription activated!');
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
            return;
          }
        }

        attempts++;
      }

      if (!mounted) return;

      // Show timeout dialog with retry option
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Payment Timeout'),
              content: const Text(
                'We could not confirm your payment after several attempts.\n'
                'Please check your transaction or try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pollForConfirmation(); // Retry polling
                  },
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pollForConfirmation(); // Retry on error
                  },
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // Hide spinner
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildPlanButton(String label, String plan, double price) {
    final isSelected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () => _startPayment(plan),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
            Text(
              plan == 'free' ? 'Free' : '${price.toStringAsFixed(0)} ETB',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to MSMES Shop',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select a subscription plan to continue',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 24),
                    _buildPlanButton('Free Trial (30 days)', 'free', 0),
                    _buildPlanButton('Monthly Plan', 'monthly', 100),
                    _buildPlanButton('Yearly Plan', 'yearly', 1000),
                    if (_isLoading) ...[
                      SizedBox(height: 24),
                      CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
