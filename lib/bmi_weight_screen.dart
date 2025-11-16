import 'package:flutter/material.dart';
import 'bmi_height_screen.dart';

class BmiWeightScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String gender;
  final String password;
  final int age;

  const BmiWeightScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.age,
  });

  @override
  State<BmiWeightScreen> createState() => _BmiWeightScreenState();
}

class _BmiWeightScreenState extends State<BmiWeightScreen> {
  int weight = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),
          const Text(
            "What Is Your Weight?",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),

          Text(
            "$weight Kg",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 120,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (v) {
                setState(() => weight = v + 30);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (_, i) => Center(
                  child: Text(
                    "${i + 30}",
                    style: TextStyle(
                      color: (i + 30 == weight)
                          ? Colors.white
                          : Colors.white30,
                      fontSize: (i + 30 == weight) ? 28 : 20,
                    ),
                  ),
                ),
                childCount: 150,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BmiHeightScreen(
                      userId: widget.userId,
                      name: widget.name,
                      email: widget.email,
                      gender: widget.gender,
                      password: widget.password,
                      age: widget.age,
                      weight: weight,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Continue",
                  style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
