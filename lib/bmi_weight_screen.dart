import 'package:flutter/material.dart';
import 'bmi_height_screen.dart'; 

class BmiWeightScreen extends StatefulWidget {
  final String userId;  
  final String name;
  final String email;
  final String gender;
  final String password;
  final int age;
  final String profile_image; // <-- 1. เพิ่มตัวแปรรับค่า

  const BmiWeightScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.age,
    required this.profile_image, // <-- 2. เพิ่มใน constructor
  });

  @override
  State<BmiWeightScreen> createState() => _BmiWeightScreenState();
}

class _BmiWeightScreenState extends State<BmiWeightScreen> {
  int weight = 70; // (ตัวอย่าง)

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
            "What Is Your Weight?",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),

          Text(
            "$weight kg",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 140,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: 30), // 40 + 30 = 70
              onSelectedItemChanged: (v) {
                setState(() => weight = v + 40); // เริ่มที่ 40kg
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (_, i) => Center(
                  child: Text(
                    "${i + 40}", // เริ่มที่ 40kg
                    style: TextStyle(
                      color: (i + 40 == weight) ? Colors.white : Colors.white30,
                      fontSize: (i + 40 == weight) ? 28 : 20,
                    ),
                  ),
                ),
                childCount: 160, // 40 - 200kg
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BmiHeightScreen( // <-- ไปหน้า Height
                      userId: widget.userId,
                      name: widget.name,
                      email: widget.email,
                      gender: widget.gender,
                      password: widget.password,
                      age: widget.age,
                      weight: weight, // <-- ส่ง weight ที่เลือก
                      profile_image: widget.profile_image, // <-- 3. ส่งต่อ
                    ),
                  ),
                );
              },
               style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Continue",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}