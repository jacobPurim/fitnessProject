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

  final Map<String, String> dayNameMap = {
    "Monday": "จันทร์",
    "Tuesday": "อังคาร",
    "Wednesday": "พุธ",
    "Thursday": "พฤหัส",
    "Friday": "ศุกร์",
    "Saturday": "เสาร์",
    "Sunday": "อาทิตย์",
  };

  String selectedDay = "Monday";
  
  // เก็บข้อมูลชั่วคราวเพื่อไม่ให้หายตอนสลับวัน
  Map<String, List<Map<String, dynamic>>> tempSchedule = {};

  List<Map<String, dynamic>> exercises = [];

  // ✅ ตั้งค่า IP และ Folder
  final String _baseUrl = "http://10.0.2.2";
  final String _apiFolder = "flutter_api"; 

  @override
  void initState() {
    super.initState();
    
    // คัดลอกข้อมูลเดิมลงตัวแปร tempSchedule
    for (var day in days) {
      tempSchedule[day] = widget.existing[day]?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    }
    
    loadExercises();
  }

  Future<void> loadExercises() async {
    try {
      final res = await http.get(
        Uri.parse("$_baseUrl/$_apiFolder/get_exercises.php"),
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

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "https://via.placeholder.com/120x120?text=No+Image";
    
    String finalUrl = url;

    if (url.startsWith("http")) {
      // แก้ IP ให้ตรงกับ _baseUrl (10.0.2.2)
      if (url.contains("localhost") || url.contains("127.0.0.1")) {
        finalUrl = url.replaceAll("localhost", "10.0.2.2")
                      .replaceAll("127.0.0.1", "10.0.2.2");
      }
      
      // ✅ แก้ไขจุดที่ Error: ถ้าเจอ fitness_exercises_api ให้เปลี่ยนเป็น flutter_api
      if (finalUrl.contains("fitness_exercises_api")) {
         finalUrl = finalUrl.replaceAll("fitness_exercises_api", _apiFolder);
      }
    } else {
      // ถ้ามาแค่ชื่อไฟล์
      if (url.startsWith("uploads/")) {
         finalUrl = "$_baseUrl/$_apiFolder/$url";
      } else {
         finalUrl = "$_baseUrl/$_apiFolder/uploads/$url";
      }
    }
    
    return finalUrl;
  }

  // บันทึกข้อมูลของ "ทุกวัน" ในรอบเดียว
  Future<void> saveSchedule() async {
    try {
      // ใช้ save_schedule_all.php (แบบส่งทีเดียว) หรือ save_schedule.php (แบบวนลูป) ก็ได้
      // ในที่นี้ใช้วิธีวนลูปส่งทีละวันตามโค้ดเดิมของคุณเพื่อความชัวร์กับ backend เดิม
      final url = Uri.parse("$_baseUrl/$_apiFolder/save_schedule.php");
      
      List<Future> requests = [];

      tempSchedule.forEach((dayKey, exs) {
         final body = {
          "user_id": widget.userId.toString(),
          "day": dayKey, 
          "exercises": json.encode(exs),
          "clear_old": "1",
        };
        requests.add(http.post(url, body: body));
      });

      await Future.wait(requests);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("บันทึกตารางครบทุกวันเรียบร้อยแล้ว")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error saving: $e");
    }
  }

  void toggleExercise(Map<String, dynamic> ex) {
    setState(() {
      final currentDayList = tempSchedule[selectedDay]!;
      final index = currentDayList.indexWhere((x) => x['name'] == ex['name']);

      if (index >= 0) {
        currentDayList.removeAt(index);
      } else {
        currentDayList.add(Map.from(ex));
      }
    });
  }

  Widget _dayButton(String engDay) {
    final active = engDay == selectedDay;
    final String labelToShow = dayNameMap[engDay] ?? engDay; 

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = engDay; 
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
          labelToShow,
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
        title: const Text("ตารางออกกำลังกาย"),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text(
                  "เลือกท่าออกกำลังกาย",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "(${dayNameMap[selectedDay]})",
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 1,
              padding: const EdgeInsets.all(12),
              childAspectRatio: 3 / 1.3,
              children: exercises.map((ex) {
                final sel = tempSchedule[selectedDay]!.any((x) => x['name'] == ex['name']);
                final imageUrl = _fixImageUrl(ex['image_url']);

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
                            )
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
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
                          if (sel)
                             const Padding(
                               padding: EdgeInsets.only(right: 8.0),
                               child: Icon(Icons.check_circle, color: Colors.redAccent),
                             )
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