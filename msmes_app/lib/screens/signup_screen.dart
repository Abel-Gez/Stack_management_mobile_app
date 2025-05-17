import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password2 = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();

  String _role = 'retailer';
  bool _agreeTerms = false;
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate() && _agreeTerms) {
      setState(() => _isLoading = true);

      // Build request body dynamically
      final Map<String, dynamic> requestData = {
        "username": _username.text,
        "phone_number": _phone.text,
        "password": _password.text,
        "password2": _password2.text,
        "role": _role,
      };

      // Only add business fields if needed
      if (_role == 'retailer' || _role == 'wholesaler') {
        requestData['business_name'] = _businessNameController.text;
        requestData['business_address'] = _businessAddressController.text;
      }

      final success = await ApiService.signupFromMap(requestData);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup successful!')));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed. Check info or try again.')),
        );
      }
    } else if (!_agreeTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You must agree to the terms!')));
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.lightBlue.shade50,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                'MSMES SHOP',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'SIGN UP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _username,
                    decoration: _buildInputDecoration('Username'),
                    validator: (val) => val!.isEmpty ? 'Enter username' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    decoration: _buildInputDecoration('Phone Number'),
                    validator:
                        (val) => val!.isEmpty ? 'Enter phone number' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: _buildInputDecoration('Password'),
                    validator:
                        (val) =>
                            val!.length < 6 ? 'Minimum 6 characters' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _password2,
                    obscureText: true,
                    decoration: _buildInputDecoration('Confirm Password'),
                    validator:
                        (val) =>
                            val != _password.text
                                ? 'Passwords do not match'
                                : null,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items:
                        ['retailer', 'wholesaler'].map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                    onChanged: (val) => setState(() => _role = val!),
                    decoration: _buildInputDecoration('Select Role'),
                  ),
                  SizedBox(height: 12),

                  // ✅ Business Fields shown conditionally
                  if (_role == 'retailer' || _role == 'wholesaler') ...[
                    TextFormField(
                      controller: _businessNameController,
                      decoration: _buildInputDecoration('Business Name'),
                      validator:
                          (val) => val!.isEmpty ? 'Enter business name' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _businessAddressController,
                      decoration: _buildInputDecoration(
                        'Business Address (Optional)',
                      ),
                    ),
                    SizedBox(height: 12),
                  ],

                  CheckboxListTile(
                    title: Text(
                      "Agree terms & conditions",
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _agreeTerms,
                    onChanged:
                        (val) => setState(() => _agreeTerms = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Sign-up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  SizedBox(height: 30),
                  Image.asset('assets/images/shop.png', height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
