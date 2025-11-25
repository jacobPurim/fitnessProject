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
  
  // ✅ แก้ไข 1: เปลี่ยนชื่อวันเป็นภาษาไทย
  final List<String> days = [
    "วันจันทร์",
    "วันอังคาร",
    "วันพุธ",
    "วันพฤหัสบดี",
    "วันศุกร์",
    "วันเสาร์",
    "วันอาทิตย์"
  ];

  String? selectedDay;
  List<Map<String, dynamic>> exercises = [];
  List<Map<String, dynamic>> selectedExercises = [];

  final String _baseUrl = "http://10.19.205.169";
  final String _apiFolder = "flutter_api";

  @override
  void initState() {
    super.initState();
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
    // เปลี่ยน Placeholder text นิดหน่อย (ภาษาไทยใน URL อาจเพี้ยนได้ ใช้ No Image เหมือนเดิมปลอดภัยสุด)
    if (url == null || url.isEmpty) return "https://via.placeholder.com/120x120?text=No+Image";

    String finalUrl = url;

    if (url.startsWith("http")) {
      if (url.contains("localhost") || url.contains("127.0.0.1") || url.contains("10.0.2.2")) {
        finalUrl = url.replaceAll("localhost", "10.19.205.169")
                      .replaceAll("127.0.0.1", "10.19.205.169")
                      .replaceAll("10.0.2.2", "10.19.205.169");
      }
      if (finalUrl.contains("fitness_exercises_api")) {
         finalUrl = finalUrl.replaceAll("fitness_exercises_api", "flutter_api");
      }
    } else {
      if (url.startsWith("uploads/")) {
         finalUrl = "$_baseUrl/$_apiFolder/$url";
      } else {
         finalUrl = "$_baseUrl/$_apiFolder/uploads/$url";
      }
    }
    
    return finalUrl;
  }

  Future<void> saveSchedule() async {
    if (selectedDay == null) return;
    final url = Uri.parse("$_baseUrl/$_apiFolder/save_schedule.php");
    
    // หมายเหตุ: เมื่อเปลี่ยน UI วันเป็นไทย ค่าที่ส่งไป Database ก็จะเป็น "วันจันทร์" ฯลฯ
    // ตรวจสอบให้แน่ใจว่า Database ของคุณรองรับภาษาไทย (UTF-8)
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
          // ⚠️ ข้อควรระวัง: ถ้าข้อมูลเก่าใน DB เก็บ key เป็นภาษาอังกฤษ (Monday) 
          // การกดปุ่ม "วันจันทร์" อาจจะไม่โชว์ข้อมูลเก่า
          // ต้องแก้ DB ให้ key เป็นภาษาไทย หรือเขียน map แปลงค่าครับ
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
            fontFamily: 'Kanit', // แนะนำ: ถ้ามีฟอนต์ไทยสวยๆ ใส่ตรงนี้ได้
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
        // ✅ แก้ไข 2: ชื่อ AppBar ภาษาไทย
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
          // ✅ แก้ไข 3: หัวข้อส่วนเลือกท่าเป็นภาษาไทย
          const Text(
            "เลือกท่าออกกำลังกาย",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                            ),
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