import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';

class BmiResultScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String gender;
  final String password;
  final int age;
  final int weight;
  final int height;
  final String profile_image;

  const BmiResultScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.age,
    required this.weight,
    required this.height,
    required this.profile_image,
  });

  double calculateBMI() {
    double h = height / 100;
    return weight / pow(h, 2);
  }

  // ปรับปรุง: เพิ่มระดับความอ้วน 1, 2, และ 3
  String getStatus(double bmi) {
    if (bmi < 18.5) return "น้ำหนักต่ำกว่าเกณฑ์";
    if (bmi < 24.9) return "ปกติ";
    if (bmi < 29.9) return "น้ำหนักเกิน";
    if (bmi < 34.9) return "อ้วน ระดับ 1";
    if (bmi < 39.9) return "อ้วน ระดับ 2";
    return "อ้วน ระดับ 3 (อันตรายมาก)";
  }

  // ปรับปรุง: เพิ่มสีสำหรับระดับความอ้วน
  Color getStatusColor(double bmi) {
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 24.9) return Colors.greenAccent;
    if (bmi < 29.9) return Colors.orangeAccent;
    if (bmi < 34.9) return Colors.deepOrange; // อ้วนระดับ 1
    if (bmi < 39.9) return Colors.red;         // อ้วนระดับ 2
    return Colors.red[900]!;                 // อ้วนระดับ 3
  }

  // ฟังก์ชันเดิม: คำนวณช่วงน้ำหนักที่แนะนำ
  String getRecommendedWeight(int height) {
    double h = height / 100;
    // น้ำหนักต่ำสุดที่แนะนำ (BMI 18.5)
    double minWeight = 18.5 * pow(h, 2);
    // น้ำหนักสูงสุดที่แนะนำ (BMI 24.9)
    double maxWeight = 24.9 * pow(h, 2);

    return "${minWeight.toStringAsFixed(1)} - ${maxWeight.toStringAsFixed(1)} กก.";
  }

  @override
  Widget build(BuildContext context) {
    double bmi = calculateBMI();
    String status = getStatus(bmi);
    Color color = getStatusColor(bmi);
    String recommendedWeight = getRecommendedWeight(height);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. หัวข้อภาษาไทย
            const Text(
              "ผลการคำนวณ BMI", 
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),

            // 2. แสดงค่า BMI พร้อมหน่วย
            Text(
              "${bmi.toStringAsFixed(1)} BMI", 
              style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold),
            ),

            // 3. สถานะ BMI
            Text(
              status, 
              style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)
            ),
            
            const SizedBox(height: 40),

            // 4. คำอธิบายและน้ำหนักที่แนะนำ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const Text(
                    "ตามข้อมูลของคุณ:", 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18)
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "ความสูง ${height} ซม. และน้ำหนัก ${weight} กก.", 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ช่วงน้ำหนักที่แนะนำ (BMI 18.5 - 24.9):", 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18)
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recommendedWeight, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 50),

            // 5. ปุ่มดำเนินการต่อ (กลับไป HomeScreen)
            SizedBox(
              width: 260,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        userData: {
                          "id": userId,
                          "name": name,
                          "email": email,
                          "gender": gender,
                          "age": age,
                          "weight": weight,
                          "height": height,
                          "bmi": bmi,
                          "profile_image": profile_image,
                        },
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "ดำเนินการต่อ", 
                  style: TextStyle(color: Colors.white, fontSize: 20)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, 
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}