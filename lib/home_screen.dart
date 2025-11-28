import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'exercises_screen.dart';
import 'bmi_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HomeScreen({super.key, this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  
  final Map<String, String> dayTranslations = {
    "Monday": "วันจันทร์",
    "Tuesday": "วันอังคาร",
    "Wednesday": "วันพุธ",
    "Thursday": "วันพฤหัสบดี",
    "Friday": "วันศุกร์",
    "Saturday": "วันเสาร์",
    "Sunday": "วันอาทิตย์",
  };

  Map<String, List<Map<String, dynamic>>> schedule = {};
  Map<String, dynamic>? _currentUser;

  // ✅ ใช้ IP สำหรับ Emulator
  final String _baseUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev";
  final String _profileFolder = "flutter_api"; 
  final String _exerciseFolder = "flutter_api";

  @override
  void initState() {
    super.initState();
    _currentUser = widget.userData ?? {};
    schedule = {for (var d in days) d: []};
    WidgetsBinding.instance.addPostFrameCallback((_) => loadSchedule());
  }

  Map<String, dynamic> get user => _currentUser ?? widget.userData ?? {};

  String _safeString(dynamic v, [String fallback = ""]) {
    if (v == null) return fallback;
    if (v.toString().trim().isEmpty) return fallback;
    return v.toString();
  }

  int _safeInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  double _safeDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    return double.tryParse(v.toString()) ?? fallback;
  }

  String _getProfileImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) return "";
    return "$_baseUrl/$_profileFolder/uploads/profile/$filename?v=${DateTime.now().millisecondsSinceEpoch}";
  }

  // ✅ ปรับปรุง Logic การแก้ไข URL ให้ครอบคลุมและมั่นคงขึ้น
  String _getExerciseImageUrl(String? url) {
    if (url == null || url.isEmpty) return "https://via.placeholder.com/120x120?text=No+Image";
    
    String finalUrl = url;
    
    // 1. จัดการ URL แบบเต็ม (Absolute URL)
    if (url.startsWith("http")) {
       // แทนที่ localhost/127.0.0.1 ด้วย ngrok URL
       if (finalUrl.contains("localhost") || finalUrl.contains("127.0.0.1") || finalUrl.contains("//https://dermal-hae-unsteadfastly.ngrok-free.dev")) {
         finalUrl = finalUrl.replaceAll("localhost", "https://dermal-hae-unsteadfastly.ngrok-free.dev")
                           .replaceAll("127.0.0.1", "https://dermal-hae-unsteadfastly.ngrok-free.dev")
                           .replaceAll("//https://dermal-hae-unsteadfastly.ngrok-free.dev", "https://dermal-hae-unsteadfastly.ngrok-free.dev");
       }
       // แทนที่ชื่อ folder เก่าด้วย folder ปัจจุบัน
       if (finalUrl.contains("fitness_exercises_api") && _exerciseFolder == "flutter_api") {
          finalUrl = finalUrl.replaceAll("fitness_exercises_api", _exerciseFolder);
       }
    } else {
       // 2. จัดการ URL สัมพัทธ์ (Relative URL)
       if (url.startsWith("uploads/")) {
         finalUrl = "$_baseUrl/$_exerciseFolder/$url";
       } else {
         finalUrl = "$_baseUrl/$_exerciseFolder/uploads/$url";
       }
    }
    return finalUrl;
  }

  Future<void> loadSchedule() async {
    final rawId = user['id'];
    final userId = _safeInt(rawId, 0);
    if (userId == 0) return;

    try {
      final url = Uri.parse("$_baseUrl/$_profileFolder/get_schedule.php?user_id=$userId");
      
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        schedule = {for (var d in days) d: []};
        for (var row in data) {
          final day = _safeString(row['day']);
          if (!schedule.containsKey(day)) continue;
          schedule[day]!.add({
            // ✅ ดึง ID มาด้วย (สำคัญสำหรับใช้ในการเปรียบเทียบใน ScheduleScreen)
            "id": _safeString(row["exercise_id"]), 
            "name": _safeString(row["exercise_name"]),
            "type": _safeString(row["exercise_type"]),
            "image_url": _safeString(row["image_url"]), 
          });
        }
        setState(() {});
      }
    } catch (e) {
      print("loadSchedule error: $e");
    }
  }

  Future<void> openSchedule() async {
    final userId = _safeInt(user['id']);
    // **สำคัญ:** ScheduleScreen ต้องได้รับ ID ของท่าออกกำลังกายด้วย
    final refreshed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScheduleScreen(userId: userId, existing: schedule)),
    );
    if (refreshed == true) loadSchedule();
  }

  Future<void> _openProfile() async {
    final userId = user['id'];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userId: userId,
          name: _safeString(user['name']),
          email: _safeString(user['email']),
          gender: _safeString(user['gender']),
          age: _safeInt(user['age'], 20),
          weight: _safeInt(user['weight'], 70),
          height: _safeInt(user['height'], 170),
          bmi: _safeDouble(user['bmi'], 22.5),
          profile_image: _safeString(user['profile_image']),
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _currentUser = result;
      });
    }
  }

  Widget _menu(IconData icon, String text, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 234, 101, 12).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color.fromARGB(255, 234, 101, 12)),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _scheduleCard(Map<String, dynamic> ex) {
    final imgUrl = _getExerciseImageUrl(_safeString(ex['image_url'])); 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_safeString(ex['name']), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(_safeString(ex['type']), style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
            child: Image.network(
              imgUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120, height: 120, color: Colors.grey[800],
                  child: const Icon(Icons.fitness_center, color: Colors.white24),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyScheduleView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days.map((day) {
        final list = schedule[day] ?? [];
        final thaiDayName = dayTranslations[day] ?? day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thaiDayName, style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 8),
            if (list.isEmpty) const Text("—", style: TextStyle(color: Colors.white38)),
            ...list.map((e) => _scheduleCard(e)),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _safeString(user['name'], "ผู้ใช้");
    final profileImageName = _safeString(user['profile_image']);
    final profileImageUrl = _getProfileImageUrl(profileImageName);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("สวัสดี, $displayName ", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text("พร้อมลุยกันหรือยัง?", style: TextStyle(color: Color.fromARGB(255, 234, 101, 12), fontSize: 16)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _openProfile,
                    child: (profileImageName.isNotEmpty)
                        ? CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: NetworkImage(profileImageUrl),
                              onBackgroundImageError: (exception, stackTrace) {},
                            )
                        : const CircleAvatar(
                              radius: 26,
                              backgroundColor: Color.fromARGB(255, 234, 101, 12),
                              child: Icon(Icons.person, color: Colors.white)
                            ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _menu(Icons.access_time, "ตารางฝึก", openSchedule),
                  _menu(Icons.fitness_center, "ท่าบริหาร", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesScreen()));
                  }),
                  _menu(Icons.monitor_weight, "BMI", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BmiScreen()));
                  }),
                  _menu(Icons.newspaper, "ข่าวสาร", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 35),
              const Text("📅 ตารางฝึกสัปดาห์นี้", style: TextStyle(color: Color.fromARGB(255, 234, 101, 12), fontSize: 22)),
              const SizedBox(height: 18),
              _weeklyScheduleView(),
            ],
          ),
        ),
      ),
    );
  }
}