import 'package:flutter/material.dart';
import 'bmi_result_screen.dart';
import 'package:http/http.dart' as http; // <-- 1. Import
import 'dart:convert'; // <-- 2. Import

class BmiHeightScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String gender;
  final String password;
  final int age;
  final int weight;
  final String profile_image; 

  const BmiHeightScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.age,
    required this.weight,
    required this.profile_image, 
  });

  @override
  State<BmiHeightScreen> createState() => _BmiHeightScreenState();
}

class _BmiHeightScreenState extends State<BmiHeightScreen> {
  int height = 170;
  bool _isLoading = false; // <-- 3. เพิ่ม state loading

  // 4. สร้างฟังก์ชันสำหรับบันทึกและไปต่อ
  Future<void> _saveAndContinue() async {
    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse("http://10.0.2.2/flutter_api/update_bmi_data.php");
      var response = await http.post(uri, body: {
        'user_id': widget.userId,
        'age': widget.age.toString(),
        'height': height.toString(),
        'weight': widget.weight.toString(),
      });

      var data = jsonDecode(response.body);
      
      // ตรวจสอบว่า mounted (Widget ยังอยู่บนหน้าจอ) ก่อนเรียก Navigator/SnackBar
      if (!mounted) return; 

      if (data['success'] == true) {
        // ถ้าบันทึกสำเร็จ, ไปหน้าต่อไป
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BmiResultScreen(
              userId: widget.userId,
              name: widget.name,
              email: widget.email,
              gender: widget.gender,
              password: widget.password,
              age: widget.age,
              weight: widget.weight,
              height: height,
              profile_image: widget.profile_image, 
            ),
          ),
        );
      } else {
        // ถ้าบันทึกล้มเหลว, แสดง SnackBar
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(data['message'] ?? 'Failed to save data'))
         );
      }

    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e'))
       );
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.white),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),
          const Text(
            "What Is Your Height?",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),

          Text(
            "$height cm",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 140, // เพิ่มความสูงเล็กน้อย
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              controller: FixedExtentScrollController(initialItem: 50), // 120 + 50 = 170
              onSelectedItemChanged: (v) {
                setState(() => height = v + 120); // เริ่มที่ 120cm
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (_, i) => Center(
                  child: Text(
                    "${i + 120}",
                    style: TextStyle(
                      color: (i + 120 == height)
                          ? Colors.white
                          : Colors.white30,
                      fontSize: (i + 120 == height) ? 28 : 20,
                    ),
                  ),
                ),
                childCount: 100, // 120 - 220cm
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              // 5. แก้ไข onPressed
              onPressed: _isLoading ? null : _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              // 6. แก้ไข child ให้แสดง loading
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
            ),
          )
        ],
      ),
    );
  }
}