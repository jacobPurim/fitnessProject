import 'package:flutter/material.dart';
import 'bmi_weight_screen.dart'; 
// import 'register_screen.dart'; // อาจต้องใช้ถ้าต้องการ pushReplacement กลับไป

class BmiAgeScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String gender;
  final String password;
  final String profile_image; 

  const BmiAgeScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.profile_image, 
  });

  @override
  State<BmiAgeScreen> createState() => _BmiAgeScreenState();
}

class _BmiAgeScreenState extends State<BmiAgeScreen> {
  int age = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Back Button: ใช้ pop เพื่อกลับไปหน้า RegisterScreen และคงข้อมูลที่กรอกไว้
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),

          // 1. หัวข้อภาษาไทย
          const Text(
            "คุณอายุเท่าไหร่?",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 2. แสดงตัวเลขปัจจุบัน (แสดงหน่วย "ปี" ไว้)
          Text(
            "$age ปี", 
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80, 
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // 3. ปรับปรุง ListWheelScrollView (ลบ "ปี" ออกจากรายการ)
          Expanded( 
            child: Center(
              child: SizedBox(
                height: 200, 
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50, 
                  diameterRatio: 1.5, 
                  perspective: 0.005, 
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (v) {
                    setState(() => age = v + 10);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (_, i) {
                      final currentAge = i + 10;
                      final isSelected = currentAge == age;
                      return Center(
                        child: Text(
                          "$currentAge", // ลบหน่วย "ปี" ออก
                          style: TextStyle(
                            color: isSelected ? Colors.orange : Colors.white70,
                            fontSize: isSelected ? 36 : 24, 
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    childCount: 70,
                  ),
                ),
              ),
            ),
          ),
          
          // 4. ปุ่ม Continue ภาษาไทย 
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BmiWeightScreen(
                      userId: widget.userId,
                      name: widget.name,
                      email: widget.email,
                      gender: widget.gender,
                      password: widget.password,
                      age: age, 
                      profile_image: widget.profile_image, 
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 56), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5, 
              ),
              child: const Text(
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