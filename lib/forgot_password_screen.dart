import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // สถานะสำหรับปุ่ม Loading

  // URL API สำหรับการส่งอีเมลลืมรหัสผ่าน
  final String _apiUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev/flutter_api/forgot_password.php"; 

  // -------------------------
  // ฟังก์ชันสำหรับการส่งอีเมลรีเซ็ต
  // -------------------------
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    // ปิดคีย์บอร์ดก่อนส่ง
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true; // เริ่ม Loading
    });

    try {
      var response = await http.post(
        Uri.parse(_apiUrl),
        body: {'email': _emailController.text.trim()},
      );

      // ตรวจสอบสถานะการตอบกลับ
      if (response.statusCode != 200) {
        throw Exception("Server responded with status code: ${response.statusCode}");
      }

      var data = jsonDecode(response.body);

      // แสดง SnackBar ตามผลลัพธ์จาก Server
      final snackBar = SnackBar(
        content: Text(data["message"] ?? "เกิดข้อผิดพลาดไม่ทราบสาเหตุ"),
        backgroundColor: data["success"] == true ? Colors.green : Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (data["success"] == true) {
        // หากส่งสำเร็จ ให้เคลียร์ช่องกรอกอีเมลและกลับไปหน้า Login
        _emailController.clear();
        // หน่วงเวลา 2 วินาทีเพื่อให้ผู้ใช้เห็น SnackBar ก่อนกลับหน้า
        await Future.delayed(const Duration(seconds: 2)); 
        Navigator.pop(context); 
      }
      
    } catch (e) {
      print("Error sending reset email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่ (Server ไม่ตอบสนองหรือมีปัญหา)"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // หยุด Loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ลืมรหัสผ่าน", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              const Icon(Icons.lock_reset, color: Color(0xFFFF6A00), size: 60),
              const SizedBox(height: 20),
              const Text(
                "รีเซ็ตรหัสผ่าน",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "เราจะส่งลิงก์รีเซ็ตไปให้ทางอีเมลของคุณ",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("อีเมล"),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "กรุณาใส่อีเมลของคุณ";
                  }
                  // เพิ่ม Regular Expression สำหรับตรวจสอบรูปแบบอีเมลเบื้องต้น
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v)) {
                    return "รูปแบบอีเมลไม่ถูกต้อง";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetEmail, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                        )
                      : const Text(
                            "ส่งลิงก์รีเซ็ต",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // รูปแบบ Input Decoration สำหรับ Text Field
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFFF6A00), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}