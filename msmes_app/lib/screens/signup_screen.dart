import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();

  String _role = 'retailer';
  bool _agreeTerms = false;
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate() && _agreeTerms) {
      setState(() => _isLoading = true);

      final requestData = {
        "username": _username.text,
        "email": _email.text,
        "phone_number": _phone.text,
        "password": _password.text,
        "password2": _password2.text,
        "role": _role,
      };

      if (_role == 'retailer' || _role == 'wholesaler') {
        requestData['business_name'] = _businessNameController.text;
        requestData['business_address'] = _businessAddressController.text;
      }

      final result = await ApiService.signupFromMap(requestData);
      final success = result['success'] == true;

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Logging in...')),
        );
        _loginAfterSignup(); // ⬅ Auto login after successful signup
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Try again.')),
        );
      }
    } else if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms.')),
      );
    }
  }

  Future<void> _loginAfterSignup() async {
    final result = await ApiService.loginWithSubscription(
      phone: _phone.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final status = result['subscription_status'];

      Navigator.pushReplacementNamed(
        context,
        status == 'active' ? '/home' : '/subscribe',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed after signup.')),
      );
    }
  }

  InputDecoration _inputStyle(String label, {IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.cyan[700]) : null,
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              SizedBox(height: height * 0.04),
              Center(
                child: Text(
                  'MSMES SHOP',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.cyan.shade700,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _username,
                      decoration: _inputStyle('Username', icon: Icons.person),
                      validator:
                          (val) => val!.isEmpty ? 'Enter your username' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputStyle('Email', icon: Icons.email),
                      validator:
                          (val) =>
                              val == null || !val.contains('@')
                                  ? 'Enter a valid email'
                                  : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: _inputStyle(
                        'Phone Number',
                        icon: Icons.phone,
                      ),
                      validator:
                          (val) =>
                              val!.isEmpty ? 'Enter your phone number' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: _inputStyle('Password', icon: Icons.lock),
                      validator:
                          (val) =>
                              val!.length < 6
                                  ? 'Minimum 6 characters required'
                                  : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password2,
                      obscureText: true,
                      decoration: _inputStyle(
                        'Confirm Password',
                        icon: Icons.lock,
                      ),
                      validator:
                          (val) =>
                              val != _password.text
                                  ? 'Passwords do not match'
                                  : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: _inputStyle('Select Role'),
                      items:
                          ['retailer', 'wholesaler']
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.toUpperCase()),
                                ),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _role = val!),
                    ),
                    const SizedBox(height: 14),
                    if (_role == 'retailer' || _role == 'wholesaler') ...[
                      TextFormField(
                        controller: _businessNameController,
                        decoration: _inputStyle(
                          'Business Name',
                          icon: Icons.business,
                        ),
                        validator:
                            (val) =>
                                val!.isEmpty
                                    ? 'Enter your business name'
                                    : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _businessAddressController,
                        decoration: _inputStyle(
                          'Business Address (Optional)',
                          icon: Icons.location_on,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    CheckboxListTile(
                      value: _agreeTerms,
                      onChanged: (val) => setState(() => _agreeTerms = val!),
                      title: const Text(
                        "I agree to the Terms & Conditions",
                        style: TextStyle(fontSize: 14),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan[700],
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Image.asset('assets/images/shop.png', height: 100),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
