import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetCompleteScreen extends StatefulWidget {
  final String uidb64;
  final String token;

  const PasswordResetCompleteScreen({
    super.key,
    required this.uidb64,
    required this.token,
  });

  @override
  State<PasswordResetCompleteScreen> createState() =>
      _PasswordResetCompleteScreenState();
}

class _PasswordResetCompleteScreenState
    extends State<PasswordResetCompleteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPassword.text != _confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'http://192.168.1.113:8000/api/auth/password-reset-complete/',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'password': _newPassword.text.trim(),
          'token': widget.token,
          'uidb64': widget.uidb64,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['detail'] ?? 'Reset failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00BCD4), Color(0xFF3F51B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Set New Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _newPassword,
                        obscureText: true,
                        decoration: _inputDecoration('New Password'),
                        validator:
                            (val) =>
                                val == null || val.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPassword,
                        obscureText: true,
                        decoration: _inputDecoration('Confirm Password'),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Confirm your password'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitReset,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.white.withOpacity(0.85),
                            shape: const StadiumBorder(),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.cyan,
                                  )
                                  : Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      color: Colors.cyan.shade700,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
