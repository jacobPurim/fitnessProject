import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../exercise_video_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List exercises = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    const url = "http://10.0.2.2/fitness_exercises_api/get_exercises.php";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        setState(() {
          exercises = json.decode(res.body);
          loading = false;
        });
      } else {
        debugPrint("❌ Server returned ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error loading exercises: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Exercise Library", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, i) {
                final ex = exercises[i];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseVideoScreen(
                          name: ex["name"],
                          videoUrl: ex["video_url"],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            ex["image_url"] ?? "",
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ex["name"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          ex["category"] ?? "",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
