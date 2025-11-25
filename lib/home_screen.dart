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
  // ⚠️ list นี้ต้องเป็นภาษาอังกฤษเหมือนเดิมเพื่อให้ตรงกับ Database/API
  final List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  
  // ✅ เพิ่มตัวแปลงภาษาสำหรับแสดงผลวัน
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

  final String _baseUrl = "http://10.19.205.169";
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

  String _getExerciseImageUrl(String? url) {
    if (url == null || url.isEmpty) return "https://via.placeholder.com/120x120?text=No+Image";
    
    String finalUrl = url;
    if (!url.startsWith("http")) {
       if (url.startsWith("uploads/")) {
         finalUrl = "$_baseUrl/$_exerciseFolder/$url";
       } else {
         finalUrl = "$_baseUrl/$_exerciseFolder/uploads/$url";
       }
    } else {
       if (url.contains("localhost") || url.contains("10.0.2.2")) {
          finalUrl = url.replaceAll("localhost", "10.19.205.169")
                        .replaceAll("10.0.2.2", "10.19.205.169");
       }
       if (finalUrl.contains("fitness_exercises_api")) {
          finalUrl = finalUrl.replaceAll("fitness_exercises_api", "flutter_api");
       }
    }
    return finalUrl;
  }

  Future<void> loadSchedule() async {
    final rawId = user['id']; 
    final userId = _safeInt(rawId, 0);
    if (userId == 0) return;

    try {
      final res = await http.get(Uri.parse("$_baseUrl/$_profileFolder/get_schedule.php?user_id=$userId"));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        schedule = {for (var d in days) d: []};
        for (var row in data) {
          final day = _safeString(row['day']);
          if (!schedule.containsKey(day)) continue;
          schedule[day]!.add({
            "name": _safeString(row["exercise_name"]),
            "type": _safeString(row["exercise_type"]),
            "image": _safeString(row["image_url"]),
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
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _scheduleCard(Map<String, dynamic> ex) {
    final imgUrl = _getExerciseImageUrl(_safeString(ex['image']));

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
        // ✅ แปลงชื่อวันภาษาอังกฤษ เป็นภาษาไทย
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
    final displayName = _safeString(user['name'], "ผู้ใช้"); // เปลี่ยน User เป็น ผู้ใช้
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
                      // ✅ แก้คำทักทาย
                      Text("สวัสดี, $displayName ", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text("พร้อมลุยกันหรือยัง?", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _openProfile,
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: ClipOval(
                        child: (profileImageName.isNotEmpty)
                            ? Image.network(
                                profileImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(Icons.person, color: Colors.white),
                                  );
                                },
                              )
                            : const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ แก้เมนูเป็นภาษาไทย
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
              // ✅ แก้หัวข้อตารางฝึก
              const Text("📅 ตารางฝึกสัปดาห์นี้", style: TextStyle(color: Colors.redAccent, fontSize: 22)),
              const SizedBox(height: 18),
              _weeklyScheduleView(),
            ],
          ),
        ),
      ),
    );
  }
}   