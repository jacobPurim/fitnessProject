import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exercise_video_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List exercises = [];
  bool loading = true;

  // ✅ IP Address เครื่องคอมพิวเตอร์ของคุณ
  final String _baseUrl = "http://10.19.205.169"; 
  final String _apiFolder = "fitness_exercises_api"; 

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    final url = "$_baseUrl/$_apiFolder/get_exercises.php"; 
    debugPrint("🚀 Fetching exercises from: $url");

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            exercises = json.decode(res.body);
            loading = false;
          });
          debugPrint("✅ Data Loaded: ${exercises.length} items");
        }
      } else {
        debugPrint("❌ Server Error: ${res.statusCode}");
        if (mounted) setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  // 🔹 ฟังก์ชันแก้ URL รูปภาพ (ฉลาดขึ้นกว่าเดิม!)
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    
    String finalUrl = url;

    // กรณีที่ 1: ถ้าใน DB เก็บเป็น URL เต็มๆ (http://...)
    if (url.startsWith("http")) {
      // ✅ เพิ่มการเช็ค "10.0.2.2" ด้วย เพื่อแก้ให้เป็น IP จริง
      if (url.contains("localhost") || url.contains("127.0.0.1") || url.contains("10.0.2.2")) {
        finalUrl = url.replaceAll("localhost", "10.19.205.169")
                      .replaceAll("127.0.0.1", "10.19.205.169")
                      .replaceAll("10.0.2.2", "10.19.205.169"); // <-- แก้ตรงนี้
      }
    } else {
      // กรณีที่ 2: ถ้าเก็บแค่ชื่อไฟล์
      if (url.startsWith("uploads/")) {
         finalUrl = "$_baseUrl/$_apiFolder/$url";
      } else {
         finalUrl = "$_baseUrl/$_apiFolder/uploads/$url"; 
      }
    }

    // แก้ปัญหาชื่อไฟล์มีเว้นวรรค (เช่น "Bench Press.jpg")
    final parts = finalUrl.split('/');
    final lastPart = parts.last;
    final encodedLastPart = Uri.encodeComponent(lastPart); 
    finalUrl = finalUrl.replaceFirst(lastPart, encodedLastPart);

    return finalUrl;
  }

  List _filterByCategory(String keyword) {
    return exercises.where((ex) {
      final category = ex['category']?.toString().toLowerCase() ?? "";
      return category.contains(keyword.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            "WORKOUT LIBRARY",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900, 
              letterSpacing: 1.2,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.white38,
            indicatorColor: Colors.redAccent,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: [
              Tab(text: "PUSH", icon: Icon(Icons.fitness_center)),
              Tab(text: "PULL", icon: Icon(Icons.rowing)),
              Tab(text: "LEGS", icon: Icon(Icons.directions_run)),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
            : TabBarView(
                children: [
                  _buildExerciseGrid(_filterByCategory("Push")),
                  _buildExerciseGrid(_filterByCategory("Pull")),
                  _buildExerciseGrid(_filterByCategory("Leg")),
                ],
              ),
      ),
    );
  }

  Widget _buildExerciseGrid(List data) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.fitness_center, size: 64, color: Colors.white12),
            SizedBox(height: 16),
            Text("No exercises yet", style: TextStyle(color: Colors.white30)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, i) {
        final ex = data[i];
        return _buildModernCard(ex);
      },
    );
  }

  Widget _buildModernCard(dynamic ex) {
    // ✅ เรียกใช้ฟังก์ชันแก้ URL
    final String imageUrl = _fixImageUrl(ex["image_url"]);
    
    // เช็คว่ามีวิดีโอไหม
    final bool hasVideo = ex["video_url"] != null && ex["video_url"].toString().isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseVideoScreen(
                name: ex["name"],
                videoUrl: ex["video_url"],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No video available for this exercise")),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl, 
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent.withOpacity(0.5),
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey[900],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.broken_image, color: Colors.white24),
                        SizedBox(height: 4),
                        Text("No Image", style: TextStyle(color: Colors.white24, fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
              
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8), 
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),

              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex["name"] ?? "Unknown",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ex["sets"] ?? "3 sets",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (hasVideo)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}