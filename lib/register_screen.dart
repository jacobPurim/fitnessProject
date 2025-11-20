import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _pickedImage;

  // -------------------------
  // เลือกรูปโปรไฟล์
  // -------------------------
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  // -------------------------
  // REGISTER + UPLOAD IMAGE
  // -------------------------
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    var uri = Uri.parse("http://10.0.2.2/flutter_api/register.php");
    var request = http.MultipartRequest("POST", uri);

    request.fields['name'] = _nameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['password'] = _passwordController.text.trim();
    request.fields['gender'] = _selectedGender ?? "";

    // ถ้ามีรูป → แนบไปกับ POST
    if (_pickedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        _pickedImage!.path,
      ));
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    var data = jsonDecode(responseBody);

    print("REGISTER RESPONSE = $data");

    if (data["success"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BmiAgeScreen(
            userId: data["user_id"].toString(),
            name: data["name"],
            email: data["email"],
            gender: data["gender"],
            password: data["password"],
            profile_image: data["profile_image"] ?? "", // <-- แก้ไขตรงนี้
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Register failed")),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // -------------------------
                // PROFILE IMAGE PICKER
                // -------------------------
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white12,
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? const Icon(Icons.camera_alt,
                            color: Colors.white70, size: 28)
                        : null,
                  ),
                ),

                const SizedBox(height: 25),

                // -------------------------
                // FULL NAME
                // -------------------------
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Full Name"),
                  validator: (v) =>
                      v!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 16),

                // -------------------------
                // EMAIL
                // -------------------------
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Email"),
                  validator: (v) =>
                      v!.isEmpty ? "Please enter your email" : null,
                ),
                const SizedBox(height: 16),

                // -------------------------
                // PASSWORD
                // -------------------------
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Password"),
                  validator: (v) =>
                      v!.length < 6 ? "Password too short" : null,
                ),
                const SizedBox(height: 16),

                // -------------------------
                // GENDER SELECTOR
                // -------------------------
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Gender",
                      style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _genderButton("Male", Icons.male),
                    const SizedBox(width: 12),
                    _genderButton("Female", Icons.female),
                  ],
                ),

                const SizedBox(height: 40),

                // -------------------------
                // REGISTER BUTTON
                // -------------------------
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

                // -------------------------
                // LOGIN LINK
                // -------------------------
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.orange),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Gender button widget
  // -------------------------
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

  // -------------------------
  // Input decoration
  // -------------------------
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