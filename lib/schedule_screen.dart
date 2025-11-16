// lib/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleScreen extends StatefulWidget {
  final int userId;
  final Map<String, List<Map<String, dynamic>>> existing;

  const ScheduleScreen({
    super.key,
    required this.userId,
    required this.existing,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  String? selectedDay;
  List<Map<String, dynamic>> exercises = [];
  List<Map<String, dynamic>> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2/flutter_api/get_exercises.php"),
      );
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        exercises = list.map((e) => Map<String, dynamic>.from(e)).toList();
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error loading exercises: $e");
    }
  }

  Future<void> saveSchedule() async {
    if (selectedDay == null) return;
    final url = Uri.parse("http://10.0.2.2/flutter_api/save_schedule.php");
    final body = {
      "user_id": widget.userId.toString(),
      "day": selectedDay!,
      "exercises": json.encode(selectedExercises),
      "clear_old": "1",
    };
    final res = await http.post(url, body: body);
    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded['success'] == true) {
        Navigator.pop(context, true);
      }
    }
  }

  void toggleExercise(Map<String, dynamic> ex) {
    final idx = selectedExercises.indexWhere((x) => x['name'] == ex['name']);
    setState(() {
      if (idx >= 0) {
        selectedExercises.removeAt(idx);
      } else {
        selectedExercises.add(ex);
      }
    });
  }

  Widget _dayButton(String d) {
    final active = d == selectedDay;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = d;
          selectedExercises = widget.existing[d]
                  ?.map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              [];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: active ? Colors.redAccent : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          d,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Workout Schedule"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.check),
        onPressed: saveSchedule,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: days.map((d) => _dayButton(d)).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select Exercises",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 1,
              padding: const EdgeInsets.all(12),
              childAspectRatio: 3 / 1.3,
              children: exercises.map((ex) {
                final sel =
                    selectedExercises.any((x) => x['name'] == ex['name']);

                // ✅ ใช้ image_url จาก backend โดยตรง
                final imageUrl = (ex['image_url'] != null &&
                        ex['image_url'].toString().isNotEmpty)
                    ? ex['image_url']
                    : "https://via.placeholder.com/120x120?text=No+Image";

                return GestureDetector(
                  onTap: () => toggleExercise(ex),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 150),
                    scale: sel ? 1.03 : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sel
                            ? Colors.redAccent.withOpacity(0.15)
                            : Colors.grey[900],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: sel ? Colors.redAccent : Colors.white24,
                          width: sel ? 2 : 1.2,
                        ),
                        boxShadow: [
                          if (sel)
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ✅ รูปใหญ่เต็มสูงพอดี
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover, // 🔥 เต็มช่องแบบไม่โดนบีบ
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white54,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ✅ ข้อความอยู่ขวา ขยายเต็ม
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ex['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ex['type'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
