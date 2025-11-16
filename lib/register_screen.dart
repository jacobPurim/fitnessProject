import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'bmi_age_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/flutter_api/register.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "gender": _selectedGender ?? "",
        },
      );

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BmiAgeScreen(
              userId: data["user_id"].toString(),
              name: _nameController.text.trim(),      // ✅ ส่งไปแล้ว
              email: data["email"],
              gender: _selectedGender!,               // ✅ ส่งไปแล้ว
              password: data["password"],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Register failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Create Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ NAME
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Full Name"),
                  validator: (v) =>
                      v!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 16),

                // ✅ EMAIL
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Email"),
                  validator: (v) =>
                      v!.isEmpty ? "Please enter your email" : null,
                ),
                const SizedBox(height: 16),

                // ✅ PASSWORD
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Password"),
                  validator: (v) =>
                      v!.length < 6 ? "Password too short" : null,
                ),
                const SizedBox(height: 16),

                // ✅ GENDER SELECTOR
                const Text("Gender", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _genderButton("Male", Icons.male),
                    const SizedBox(width: 12),
                    _genderButton("Female", Icons.female),
                  ],
                ),

                const SizedBox(height: 40),

                // ✅ REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6A00),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ GO TO LOGIN
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ GENDER BUTTON
  Widget _genderButton(String gender, IconData icon) {
    final bool selected = _selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF6A00) : Colors.grey[850],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.orange : Colors.white24,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 4),
              Text(gender, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ INPUT DECORATION
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
