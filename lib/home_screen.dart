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
    "Monday", "Tuesday", "Wednesday", "Thursday",
    "Friday", "Saturday", "Sunday"
  ];

  Map<String, List<Map<String, dynamic>>> schedule = {};

  // ✅ SAFE HELPERS
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

  @override
  void initState() {
    super.initState();
    schedule = {for (var d in days) d: []};

    WidgetsBinding.instance.addPostFrameCallback((_) => loadSchedule());
  }

  // ✅ โหลดตารางเวิร์คเอาท์
  Future<void> loadSchedule() async {
    final rawId = widget.userData?['id'];
    final userId = _safeInt(rawId, 0);
    if (userId == 0) return;

    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2/flutter_api/get_schedule.php?user_id=$userId"),
      );

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

  // ✅ ไปหน้า Schedule
  Future<void> openSchedule() async {
    final userId = _safeInt(widget.userData?['id']);

    final refreshed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          userId: userId, 		// ✅ ส่งเป็น int แน่นอน
          existing: schedule,
        ),
      ),
    );

    if (refreshed == true) loadSchedule();
  }

  // ✅ UI MENU
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

  // ✅ การ์ดตารางรายวัน
  Widget _scheduleCard(Map<String, dynamic> ex) {
    final img = _safeString(ex['image']);

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
                  Text(
                    _safeString(ex['name']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _safeString(ex['type']),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Image.network(
              img.isNotEmpty ? img : "https://i.imgur.com/zYVZ9zM.jpeg",
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Weekly Schedule
  Widget _weeklyScheduleView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days.map((day) {
        final list = schedule[day] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day,
                style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 8),

            if (list.isEmpty)
              const Text("—", style: TextStyle(color: Colors.white38)),

            ...list.map((e) => _scheduleCard(e)),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData ?? {};

    final displayName = _safeString(user['name'], "User");
    final profileImage = _safeString(user['profile_image']); // <-- 1. ดึงชื่อไฟล์รูปภาพ

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $displayName 👋",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Ready to workout?",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // ✅ PROFILE ICON (Updated)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                            name: _safeString(user['name']),
                            email: _safeString(user['email']),
                            gender: _safeString(user['gender']),
                            age: _safeInt(user['age'], 20),
                            weight: _safeInt(user['weight'], 70),
                            height: _safeInt(user['height'], 170),
                            bmi: _safeDouble(user['bmi'], 22.5),
                            profile_image: profileImage, // <-- 2. ส่งชื่อไฟล์รูปไป
                          ),
                        ),
                      );
                    },
                    // 3. แสดงรูปภาพโปรไฟล์
                    child: (profileImage.isNotEmpty)
                        ? CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey[800],
                            backgroundImage: NetworkImage(
                              "http://10.0.2.2/flutter_api/uploads/profile/$profileImage",
                            ),
                          )
                        : const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                  )
                ],
              ),

              const SizedBox(height: 30),

              // ✅ MENU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _menu(Icons.access_time, "Schedule", openSchedule),
                  _menu(Icons.fitness_center, "Exercises", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ExercisesScreen()));
                  }),
                  _menu(Icons.monitor_weight, "BMI", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BmiScreen()),
                    );
                  }),
                  _menu(Icons.newspaper, "News", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewsScreen()),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                "📅 Your Weekly Schedule",
                style: TextStyle(color: Colors.redAccent, fontSize: 22),
              ),
              const SizedBox(height: 18),

              _weeklyScheduleView(),
            ],
          ),
        ),
      ),
    );
  }
}