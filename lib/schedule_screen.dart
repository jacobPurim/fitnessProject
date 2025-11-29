import 'package:flutter/material.dart';
import 'login_screen.dart';
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
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  final Map<String, String> dayNameMap = {
    "Monday": "จันทร์", "Tuesday": "อังคาร", "Wednesday": "พุธ",
    "Thursday": "พฤหัส", "Friday": "ศุกร์", "Saturday": "เสาร์", "Sunday": "อาทิตย์",
  };

  String selectedDay = "Monday";
  
  // เก็บข้อมูลตารางที่เลือก
  Map<String, List<Map<String, dynamic>>> tempSchedule = {};

  // ข้อมูลดิบทั้งหมดจาก API
  List<Map<String, dynamic>> allExercises = [];
  
  // หมวดหมู่ทั้งหมดที่มี
  List<String> allTypes = ["All"];
  // หมวดหมู่ที่กำลังเลือกอยู่
  List<String> selectedTypes = ["All"];

  final String _baseUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev";
  final String _apiFolder = "flutter_api"; 

  @override
  void initState() {
    super.initState();
    if (widget.userId == 0) {
      Future.delayed(Duration.zero, () {
        _showLoginRequiredDialog();
      });
      return;
    }
    for (var day in days) {
      tempSchedule[day] = widget.existing[day]?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    }
    
    loadExercises();
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("You must be login first!!!"),
        content: const Text("คุณต้องเข้าสู่ระบบก่อนจึงจะดูตารางออกกำลังกายได้"),
        actions: [
          TextButton(
            child: const Text("Go to Login page"),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> loadExercises() async {
    try {
      final res = await http.get(
        Uri.parse("$_baseUrl/$_apiFolder/get_exercises.php"),
      );
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        setState(() {
          allExercises = list.map((e) => Map<String, dynamic>.from(e)).toList();
          
          //ดึง Type ทั้งหมดออกมาเพื่อทำตัวกรอง ไม่ให้ซ้ำกัน
          Set<String> types = {"All"};
          for (var ex in allExercises) {
            if (ex['type'] != null && ex['type'].toString().isNotEmpty) {
              types.add(ex['type']);
            }
          }
          allTypes = types.toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading exercises: $e");
    }
  }

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "https://via.placeholder.com/120x120?text=No+Image";
    String finalUrl = url;
    if (url.startsWith("http")) {
      if (url.contains("localhost") || url.contains("127.0.0.1")) {
        finalUrl = url.replaceAll("localhost", "https://dermal-hae-unsteadfastly.ngrok-free.dev")
                      .replaceAll("127.0.0.1", "https://dermal-hae-unsteadfastly.ngrok-free.dev");
      }
      if (finalUrl.contains("fitness_exercises_api")) {
         finalUrl = finalUrl.replaceAll("fitness_exercises_api", _apiFolder);
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
    try {
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

  // ✅ ฟังก์ชันใหม่: เลือกทุกท่าที่แสดงอยู่ (Select All Visible)
  void selectAllVisible(List<Map<String, dynamic>> visibleList) {
    setState(() {
      final currentDayList = tempSchedule[selectedDay]!;
      for (var ex in visibleList) {
        // ถ้ายังไม่มีในรายการ ให้เพิ่มเข้าไป
        if (!currentDayList.any((x) => x['name'] == ex['name'])) {
           currentDayList.add(Map.from(ex));
        }
      }
    });
  }

  // ✅ ฟังก์ชันใหม่: ยกเลิกการเลือกทุกท่าที่แสดงอยู่
  void deselectAllVisible(List<Map<String, dynamic>> visibleList) {
    setState(() {
      final currentDayList = tempSchedule[selectedDay]!;
      for (var ex in visibleList) {
        currentDayList.removeWhere((x) => x['name'] == ex['name']);
      }
    });
  }

  // ✅ ฟังก์ชันจัดการตัวกรอง (เลือกได้หลายอัน)
  void _onTypeFilterSelected(String type, bool selected) {
    setState(() {
      if (type == "All") {
        selectedTypes = ["All"];
      } else {
        if (selectedTypes.contains("All")) {
          selectedTypes.remove("All");
        }
        
        if (selected) {
          selectedTypes.add(type);
        } else {
          selectedTypes.remove(type);
        }

        // ถ้าเอาออกหมด ให้กลับไปเป็น All
        if (selectedTypes.isEmpty) {
          selectedTypes = ["All"];
        }
      }
    });
  }

  Widget _dayButton(String engDay) {
    final active = engDay == selectedDay;
    final String labelToShow = dayNameMap[engDay] ?? engDay; 
    return GestureDetector(
      onTap: () {
        setState(() => selectedDay = engDay);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: active ? const Color.fromARGB(255, 234, 101, 12) : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: Colors.white, width: 1) : null,
        ),
        child: Text(
          labelToShow,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. กรองรายการที่จะแสดงตาม Categories ที่เลือก
    final visibleExercises = allExercises.where((ex) {
      if (selectedTypes.contains("All")) return true;
      return selectedTypes.contains(ex['type']);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("จัดตารางออกกำลังกาย"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // ปุ่มลัดสำหรับเลือกทั้งหมดที่เห็น
          TextButton(
             onPressed: () => selectAllVisible(visibleExercises),
             child: const Text("เลือกทั้งหมด", style: TextStyle(color: Colors.redAccent)),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 234, 101, 12),
        onPressed: saveSchedule,
        // ✅ เปลี่ยน icon ให้เป็นสีขาว
        icon: const Icon(Icons.save, color: Colors.white), 
        label: const Text("บันทึก", style: TextStyle(color: Colors.white)), // เพิ่มสีข้อความให้ชัดเจน
      ),
      body: Column(
        children: [
          // ส่วนเลือกวัน
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: days.map((d) => _dayButton(d)).toList(),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // ✅ ส่วนตัวกรอง (Filter Chips) - เลือกได้หลายอัน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: allTypes.map((type) {
                  final isSelected = selectedTypes.contains(type);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: const Color.fromARGB(255, 234, 101, 12),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey[200],
                      onSelected: (bool value) {
                        _onTypeFilterSelected(type, value);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 10),
          
          // หัวข้อบอกจำนวน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  "พบ ${visibleExercises.length} ท่า",
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                Text(
                  "กำลังจัด: ${dayNameMap[selectedDay]}",
                  style: const TextStyle(color: Color.fromARGB(255, 234, 101, 12), fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // รายการท่าออกกำลังกาย
          Expanded(
            child: visibleExercises.isEmpty 
            ? const Center(child: Text("ไม่พบข้อมูลในหมวดนี้", style: TextStyle(color: Colors.white54)))
            : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80), // เผื่อที่ให้ FAB
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, 
                childAspectRatio: 3 / 1.3,
                mainAxisSpacing: 10,
              ),
              itemCount: visibleExercises.length,
              itemBuilder: (context, index) {
                final ex = visibleExercises[index];
                // เช็คว่าท่านี้ถูกเลือกไว้ในวันปัจจุบันหรือยัง
                final sel = tempSchedule[selectedDay]!.any((x) => x['name'] == ex['name']);
                final imageUrl = _fixImageUrl(ex['image_url']);

                return GestureDetector(
                  onTap: () => toggleExercise(ex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: sel ? const Color.fromARGB(255, 234, 101, 12).withOpacity(0.2) : Colors.grey[900],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? const Color.fromARGB(255, 234, 101, 12) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // รูปภาพ
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.white54)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ข้อความ
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex['name'] ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(
                                  ex['type'] ?? 'General',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ไอคอนติ๊กถูก
                        if (sel)
                          const Padding(
                            padding: EdgeInsets.only(right: 15.0),
                            child: Icon(Icons.check_circle, color: Color.fromARGB(255, 234, 101, 12), size: 28),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}