import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

// สมมติว่าไฟล์เหล่านี้มีอยู่จริง
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
  // 🔥 1. เพิ่ม Controller สำหรับช่องยืนยันรหัสผ่าน
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedGender; // จะเก็บค่าเป็น "Male" หรือ "Female"
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
  // REGISTER + UPLOAD IMAGE (พร้อมการตรวจสอบการเลือกเพศ)
  // -------------------------
  Future<void> _register() async {
    // 1. ตรวจสอบ Validation ของ TextFormField (รวมถึงเช็ค confirm password)
    if (!_formKey.currentState!.validate()) return;

    // 2. *** บังคับเลือกเพศ (Mandatory Gender Check) ***
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกเพศด้วย")), // แจ้งเตือนภาษาไทย
      );
      return; // หยุดการทำงานถ้ายังไม่ได้เลือกเพศ
    }
    
    // URL สำหรับ API (ต้องใช้ IP address ของเครื่องคอมพิวเตอร์จริง)
    var uri = Uri.parse("https://dermal-hae-unsteadfastly.ngrok-free.dev/flutter_api/register.php"); 
    var request = http.MultipartRequest("POST", uri);

    // 3. ส่งข้อมูลเป็นภาษาอังกฤษตามเดิม: name, email, password, gender
    request.fields['name'] = _nameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['password'] = _passwordController.text.trim();
    request.fields['gender'] = _selectedGender!; // ส่งค่า "Male" หรือ "Female"

    // ถ้ามีรูป → แนบไปกับ POST (ใช้ field name 'profile_image' เหมือนเดิม)
    if (_pickedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        _pickedImage!.path,
      ));
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    // ป้องกันกรณี Server ส่ง Error HTML กลับมาแทน JSON
    try {
      var data = jsonDecode(responseBody);
      print("REGISTER RESPONSE = $data");

      if (data["success"] == true) {
        // ส่งค่าไปยังหน้าถัดไป
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BmiAgeScreen(
              userId: data["user_id"].toString(),
              name: data["name"],
              email: data["email"],
              gender: data["gender"],
              password: data["password"],
              profile_image: data["profile_image"] ?? "",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "ลงทะเบียนไม่สำเร็จ")),
        );
      }
    } catch (e) {
      print("Error parsing JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $responseBody")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar ถูกนำออกเพื่อลบปุ่มย้อนกลับด้านบนซ้าย
      
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -------------------------
                // TITLE (ภาษาไทย)
                // -------------------------
                const SizedBox(height: 40),
                const Text(
                  "สร้างบัญชีใหม่",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                // -------------------------
                // PROFILE IMAGE LABEL (ใหม่: "รูปโปรไฟล์ (ไม่บังคับ)")
                // -------------------------
                const Text(
                  "รูปโปรไฟล์ (ไม่บังคับ)",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10), // เว้นระยะห่างจาก CircleAvatar

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
                // FULL NAME (ภาษาไทย)
                // -------------------------
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("ชื่อ-นามสกุล"),
                  validator: (v) =>
                      v!.isEmpty ? "กรุณาใส่ชื่อ-นามสกุลของคุณ" : null,
                ),
                const SizedBox(height: 16),

                // -------------------------
                // EMAIL (ภาษาไทย)
                // -------------------------
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("อีเมล"),
                  validator: (v) =>
                      v!.isEmpty ? "กรุณาใส่อีเมลของคุณ" : null,
                ),
                const SizedBox(height: 16),

                // -------------------------
                // PASSWORD (ภาษาไทย)
                // -------------------------
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("รหัสผ่าน"),
                  validator: (v) =>
                      v!.length < 6 ? "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร" : null,
                ),
                const SizedBox(height: 16),

                // 🔥 2. เพิ่มช่องยืนยันรหัสผ่าน (UI + Logic Check)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("ยืนยันรหัสผ่าน"),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "กรุณายืนยันรหัสผ่าน";
                    }
                    // 🔥 3. เช็คว่าตรงกับช่องแรกไหม
                    if (v != _passwordController.text) {
                      return "รหัสผ่านไม่ตรงกัน";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // -------------------------
                // GENDER SELECTOR (ภาษาไทย)
                // -------------------------
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("เพศ",
                      style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    // 'ชาย' สำหรับแสดงผล, 'Male' สำหรับส่ง DB
                    _genderButton("ชาย", Icons.male, "Male"), 
                    const SizedBox(width: 12),
                    // 'หญิง' สำหรับแสดงผล, 'Female' สำหรับส่ง DB
                    _genderButton("หญิง", Icons.female, "Female"), 
                  ],
                ),

                const SizedBox(height: 40),

                // -------------------------
                // REGISTER BUTTON (ภาษาไทย)
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
                      "ลงทะเบียน",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // -------------------------
                // LOGIN LINK (ภาษาไทย)
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
                    "มีบัญชีอยู่แล้ว? เข้าสู่ระบบ",
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
  // Gender button widget (รับค่า 2 ค่า: UI และ DB)
  // -------------------------
  Widget _genderButton(String displayGender, IconData icon, String dbValue) {
    final bool selected = _selectedGender == dbValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = dbValue),
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
              // แสดงข้อความภาษาไทย
              Text(displayGender, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }


  // -------------------------
  // Input decoration (แสดง hint เป็นภาษาไทย)
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