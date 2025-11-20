import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';
import 'profile_screen.dart';

class BmiResultScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String gender;
  final String password;
  final int age;
  final int weight;
  final int height;
  final String profile_image; // <-- 1. เพิ่มตัวแปรรับค่า

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
    required this.profile_image, // <-- 2. เพิ่มใน constructor
  });

  double calculateBMI() {
    double h = height / 100;
    return weight / pow(h, 2);
  }

  String getStatus(double bmi) {
    if (bmi < 18.5) return "น้ำหนักต่ำกว่าเกณฑ์";
    if (bmi < 24.9) return "ปกติ";
    if (bmi < 29.9) return "น้ำหนักเกิน";
    return "อ้วน";
  }

  Color getStatusColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24.9) return Colors.green;
    if (bmi < 29.9) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    double bmi = calculateBMI();
    String status = getStatus(bmi);
    Color color = getStatusColor(bmi);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.white),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your BMI",
                style: TextStyle(color: Colors.white70, fontSize: 26)),

            Text(
              bmi.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 70,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              status,
              style: TextStyle(color: color, fontSize: 28),
            ),

            const SizedBox(height: 40),

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
                          "profile_image": profile_image, // <-- 3. ส่ง profile_image ไป Home
                        },
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("Continue",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 260,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        name: name,
                        email: email,
                        gender: gender,
                        age: age,
                        weight: weight,
                        height: height,
                        bmi: bmi,
                        profile_image: profile_image, // <-- 4. ส่ง profile_image ไป Profile
                      ),
                    ),
                  );
                },
                child: const Text("View Profile",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}