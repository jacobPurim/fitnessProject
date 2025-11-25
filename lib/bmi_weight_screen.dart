import 'package:flutter/material.dart';
import 'bmi_height_screen.dart'; // ตรวจสอบว่ามีไฟล์นี้อยู่ในโปรเจกต์ของคุณ

class BmiWeightScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String gender;
  final String password;
  final int age;
  final String profile_image; // ตัวแปรรับค่า

  const BmiWeightScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.age,
    required this.profile_image, // ใน constructor
  });

  @override
  State<BmiWeightScreen> createState() => _BmiWeightScreenState();
}

class _BmiWeightScreenState extends State<BmiWeightScreen> {
  int weight = 70;

  @override
  Widget build(BuildContext context) {
    // กำหนดค่าเริ่มต้นสำหรับ ListWheelScrollView
    // 70 kg คือ index 30 (70 - 40)
    final initialItemIndex = weight - 40;

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
            "น้ำหนักของคุณเท่าไหร่?",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 2. แสดงตัวเลขปัจจุบัน (แสดงหน่วย "kg" ไว้)
          Text(
            "$weight กก.", // <-- แสดงหน่วย " กก."
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 3. ListWheelScrollView สไตล์เรียบง่าย (ลบหน่วย "kg" ออก)
          Expanded( 
            child: Center(
              child: SizedBox(
                height: 200, // เพิ่มความสูงให้เห็นรายการได้มากขึ้น
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50, // ปรับให้ดูสบายตา
                  diameterRatio: 1.5,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  // กำหนดค่าเริ่มต้น
                  controller: FixedExtentScrollController(initialItem: initialItemIndex), 
                  onSelectedItemChanged: (v) {
                    setState(() => weight = v + 40); // เริ่มที่ 40kg
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (_, i) {
                      final currentWeight = i + 40;
                      final isSelected = currentWeight == weight;
                      return Center(
                        child: Text(
                          "$currentWeight", // <-- ลบหน่วย "kg" ออก
                          style: TextStyle(
                            color: isSelected ? Colors.orange : Colors.white70,
                            fontSize: isSelected ? 36 : 24, // เพิ่มขนาดตัวเลขที่เลือกให้ใหญ่ขึ้น
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    childCount: 160, // 40 - 200kg
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
                    builder: (_) => BmiHeightScreen( // ไปหน้า BmiHeightScreen
                      userId: widget.userId,
                      name: widget.name,
                      email: widget.email,
                      gender: widget.gender,
                      password: widget.password,
                      age: widget.age,
                      weight: weight, // ส่ง weight ที่เลือก
                      profile_image: widget.profile_image, // ส่งต่อ
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