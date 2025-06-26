import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;

  // void _login() async {
  //   final phone = _phone.text.trim();
  //   final password = _password.text;

  //   if (phone.isEmpty || password.isEmpty) {
  //     _showSnackBar('Please enter phone number and password.');
  //     return;
  //   }

  //   final result = await ApiService.login(phone: phone, password: password);

  //   if (!mounted) return;

  //   if (result?['success'] == true) {
  //     final status = result?['subscription_status'];
  //     if (status == 'active') {
  //       Navigator.pushReplacementNamed(context, '/home');
  //     } else {
  //       Navigator.pushReplacementNamed(context, '/subscribe');
  //     }
  //   } else {
  //     _showSnackBar('Login failed. Please check your credentials.');
  //   }
  // }

  // void _showSnackBar(String message, {Color color = Colors.red}) {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  // }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await ApiService.loginWithSubscription(
        phone: _phone.text,
        password: _password.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        final subscriptionStatus = result['subscription_status'];
        if (subscriptionStatus == 'active') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/subscribe');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed')),
        );
      }
    }
  }

  // void _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() => _isLoading = true);

  //     final success = await ApiService.login(
  //       phone: _phone.text,
  //       password: _password.text,
  //     );

  //     if (!mounted) return;

  //     setState(() => _isLoading = false);

  //     if (success) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Login successful!')));
  //       Navigator.pushReplacementNamed(context, '/home');
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Invalid phone or password.')));
  //     }
  //   }
  // }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MSMES SHOP',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: _buildInputDecoration('Phone Number'),
                            validator:
                                (val) =>
                                    val!.isEmpty ? 'Enter phone number' : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            decoration: _buildInputDecoration('Password'),
                            validator:
                                (val) =>
                                    val!.length < 6
                                        ? 'Minimum 6 characters'
                                        : null,
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  await Navigator.pushNamed(context, '/reset');
                                } catch (e, stackTrace) {
                                  print('Navigation error: $e');
                                  print('StackTrace: $stackTrace');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Navigation failed: $e'),
                                    ),
                                  );
                                }
                              },

                              // onTap:
                              //     () => Navigator.pushNamed(context, '/reset'),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 40,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.85),
                              shape: StadiumBorder(),
                            ),
                            child:
                                _isLoading
                                    ? CircularProgressIndicator(
                                      color: Colors.cyan,
                                    )
                                    : Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.cyan.shade700,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),

                          SizedBox(height: 20),
                          GestureDetector(
                            onTap:
                                () => Navigator.pushNamed(context, '/signup'),
                            child: Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          // Image.asset('assets/images/shop.png', height: 100),
                        ],
                      ),
                    ),
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
