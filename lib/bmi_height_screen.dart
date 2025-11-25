import 'package:flutter/material.dart';
import 'bmi_result_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _isLoading = false; 

  // ฟังก์ชันสำหรับบันทึกและไปต่อ (DB Logic คงเดิม)
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
          SnackBar(content: Text(data['message'] ?? 'บันทึกข้อมูลไม่สำเร็จ'))
        );
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'))
      );
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    final initialItemIndex = height - 120;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        elevation: 0,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),
          
          // 1. หัวข้อภาษาไทย
          const Text(
            "ความสูงของคุณเท่าไหร่?",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 2. แสดงตัวเลขปัจจุบัน (แสดงหน่วย "ซม.")
          Text(
            "$height ซม.", // <-- **คงหน่วย " ซม." ไว้ตามต้องการ**
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 3. ListWheelScrollView (ลบหน่วย "ซม." ออก)
          Expanded( 
            child: Center(
              child: SizedBox(
                height: 200, 
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  diameterRatio: 1.5, 
                  perspective: 0.005, 
                  
                  controller: FixedExtentScrollController(initialItem: initialItemIndex), 
                  physics: const FixedExtentScrollPhysics(),
                  
                  onSelectedItemChanged: (v) {
                    setState(() => height = v + 120); // เริ่มที่ 120cm
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (_, i) {
                      final currentHeight = i + 120;
                      final isSelected = currentHeight == height;
                      return Center(
                        child: Text(
                          "$currentHeight", // <-- **ลบหน่วย " ซม." ออกตามต้องการ**
                          style: TextStyle(
                            color: isSelected ? Colors.orange : Colors.white70,
                            fontSize: isSelected ? 36 : 24, 
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    childCount: 100, // 120 - 220cm
                  ),
                ),
              ),
            ),
          ),

          // 4. ปุ่มดำเนินการต่อ (แสดง Loading)
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "ดำเนินการต่อ",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
            ),
          )
        ],
      ),
    );
  }
}