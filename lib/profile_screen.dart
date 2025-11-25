import 'package:flutter/material.dart';
import 'edit_profile_screen.dart'; 
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final dynamic userId;
  final String name;
  final String email;
  final String gender;
  final int age;
  final int weight;
  final int height;
  final double bmi;
  final String profile_image;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.profile_image,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _email;
  late String _gender;
  late int _age;
  late int _weight;
  late int _height;
  late double _bmi;
  late String _profileImage;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
    _gender = widget.gender;
    _age = widget.age;
    _weight = widget.weight;
    _height = widget.height;
    _bmi = widget.bmi;
    _profileImage = widget.profile_image;
  }

  // ✅ ฟังก์ชันส่งข้อมูลกลับไปหน้า Home (เพื่อให้ Home อัปเดตทันที)
  void _goBackWithData() {
    final updatedData = {
      "id": widget.userId,
      "name": _name,
      "email": _email,
      "gender": _gender,
      "age": _age,
      "weight": _weight,
      "height": _height,
      "bmi": _bmi,
      "profile_image": _profileImage,
    };
    Navigator.pop(context, updatedData);
  }

  // ฟังก์ชันเปิดหน้า Edit Profile
  Future<void> _openEditProfile() async {
    final currentData = {
      "id": widget.userId,
      "name": _name,
      "email": _email,
      "gender": _gender,
      "age": _age,
      "weight": _weight,
      "height": _height,
      "bmi": _bmi,
      "profile_image": _profileImage,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userData: currentData),
      ),
    );

    // ถ้ามีการแก้ไขและกด Save กลับมา -> อัปเดตหน้านี้ทันที
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _name = result['name'];
        _email = result['email'];
        _gender = result['gender'];
        _age = result['age'];
        _weight = result['weight'];
        _height = result['height'];
        _bmi = result['bmi']; 
        _profileImage = result['profile_image'];
      });
    }
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Contact Support", style: TextStyle(color: Colors.white)),
        content: const Text(
          "หากพบปัญหาการใช้งาน ติดต่อเราได้ที่:\nsupport@fitnessapp.com\nโทร: 02-123-4567",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _safeString(dynamic value, [String fallback = "-"]) {
    if (value == null) return fallback;
    if (value is String && value.trim().isEmpty) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final safeName = _safeString(_name, "User");
    final avatarLetter = (safeName.trim().isNotEmpty) ? safeName.trim()[0].toUpperCase() : "U";

    // ✅ ใช้ PopScope เพื่อดักจับการกดปุ่ม Back ของเครื่อง
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _goBackWithData(); // ส่งข้อมูลกลับเมื่อกด Back ของเครื่อง
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // ✅ ปุ่ม Back บน AppBar ก็ต้องส่งข้อมูลกลับ
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBackWithData,
          ),
          title: const Text("Profile", style: TextStyle(color: Colors.white)),
          actions: [
            // 🎧 ปุ่ม Support มุมขวาบน
            IconButton(
              icon: const Icon(Icons.support_agent, color: Colors.white),
              tooltip: "Contact Support",
              onPressed: _contactSupport,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              (_profileImage.isNotEmpty)
                  ? CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: NetworkImage(
                        // ใส่ Timestamp เพื่อแก้ Cache รูป
                        "http://10.19.205.169/flutter_api/uploads/profile/$_profileImage?v=${DateTime.now().millisecondsSinceEpoch}",
                      ),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.redAccent,
                      child: Text(avatarLetter, style: const TextStyle(color: Colors.white, fontSize: 40)),
                    ),

              const SizedBox(height: 10),

              // ✏️ ปุ่ม Edit Profile (ตรงกลาง)
              TextButton(
                onPressed: _openEditProfile,
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // ข้อมูลผู้ใช้
              _infoRow("Name", safeName),
              _infoRow("Email", _safeString(_email)),
              _infoRow("Gender", _safeString(_gender)),
              _infoRow("Age", _age.toString()),
              _infoRow("Weight", "$_weight kg"),
              _infoRow("Height", "$_height cm"),
              _infoRow("BMI", _bmi.toStringAsFixed(1)),

              const Spacer(),

              // 🔢 แสดงเวอร์ชัน v.0.0.01
              const Text(
                "v.0.0.01",
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
              const SizedBox(height: 10),

              // ปุ่ม Sign Out
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Sign Out", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}