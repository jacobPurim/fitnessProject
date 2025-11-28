import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'register_screen.dart';
// ต้อง import ไฟล์ OnboardingScreen เข้ามาด้วยเพื่อให้เข้าถึงได้
import 'main.dart'; // สมมติว่า OnboardingScreen อยู่ใน main.dart หรือคุณต้องปรับ path ให้ถูกต้อง

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    // ... (Login Logic เดิม) ...
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("https://dermal-hae-unsteadfastly.ngrok-free.dev/flutter_api/login.php"),
        body: {
          "email": _email.text.trim(),
          "password": _password.text.trim(),
        },
      );

      var data = jsonDecode(response.body);
      print("LOGIN RESPONSE: $data");

      if (data["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userData: {
                "id": data["user_id"],
                "name": data["name"],
                "email": data["email"],
                "gender": data["gender"],
                "age": data["age"],
                "height": data["height"],
                "weight": data["weight"],
                "profile_image": data["profile_image"],
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "เข้าสู่ระบบล้มเหลว")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color.fromRGBO(255, 152, 0, 1);
    
    return Scaffold(
      backgroundColor: Colors.black,
      // 1. แก้ไข AppBar ให้ใช้ IconButton เพื่อนำทางกลับไป OnboardingScreen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // **การแก้ไขเพื่อให้กลับไปที่ OnboardingScreen เสมอ**
            // ต้องมั่นใจว่า OnboardingScreen ถูก import มาแล้ว
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()), 
              (route) => false, // ล้าง Stack ทั้งหมด
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 2. โลโก้กลางจอ
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Image.asset(
                  'assets/kaitom1.png', 
                  height: 150, 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.fitness_center, size: 100, color: orangeColor); 
                  },
                ),
              ),
            ),

            const Text(
              "ยินดีต้อนรับกลับ", // Welcome Back
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // TextField สำหรับอีเมล
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "อีเมล", // Email
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.email, color: orangeColor), 
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // TextField สำหรับรหัสผ่าน
            TextField(
              controller: _password,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "รหัสผ่าน", // Password
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 197, 126, 20)), 
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            // ปุ่มเข้าสู่ระบบ (สีส้ม)
            ElevatedButton(
              onPressed: loading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 129, 26), // สีปุ่มตามค่า RGBA ที่ระบุ
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text(
                      "เข้าสู่ระบบ", // Login
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),

            // ปุ่มไปหน้าลงทะเบียน
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                "ยังไม่มีบัญชี? ลงทะเบียน", // Don't have an account? Register
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}