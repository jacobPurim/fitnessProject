import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String gender;
  final int age;
  final int weight;
  final int height;
  final double bmi;
  final String profile_image; // <-- 1. เพิ่มตัวแปรรับค่า

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.profile_image, // <-- 2. เพิ่มใน constructor
  });

  // ✅ ฟังก์ชันกัน null / ค่าว่าง ปลอดภัยแน่นอน
  String _safeString(dynamic value, [String fallback = "-"]) {
    if (value == null) return fallback;
    if (value is String && value.trim().isEmpty) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final safeName = _safeString(name, "User");
    final safeImage = _safeString(profile_image, ""); // <-- 3. ดึงชื่อไฟล์รูป

    // ✅ กันการ crash จาก safeName[0]
    final avatarLetter =
        (safeName.trim().isNotEmpty)
            ? safeName.trim()[0].toUpperCase()
            : "U";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ✅ Avatar (Updated)
            (safeImage.isNotEmpty)
                ? CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: NetworkImage(
                      "http://10.0.2.2/flutter_api/uploads/profile/$safeImage",
                    ),
                  )
                : CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),

            const SizedBox(height: 10),

            // ✅ Edit Button (ไว้อนาคต)
            TextButton(
              onPressed: () {},
              child: const Text(
                "Edit Profile",
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            _infoRow("Name", safeName),
            _infoRow("Email", _safeString(email)),
            _infoRow("Gender", _safeString(gender)),
            _infoRow("Age", age.toString()),
            _infoRow("Weight", "$weight kg"),
            _infoRow("Height", "$height cm"),
            _infoRow("BMI", bmi.toStringAsFixed(1)),

            const Spacer(),

            // ✅ Sign Out ปลอดภัย
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}