import 'package:flutter/material.dart';
import 'bmi_result_screen.dart';

class BmiHeightScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String gender;
  final String password;
  final int age;
  final int weight;

  const BmiHeightScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
    required this.age,
    required this.weight,
  });

  @override
  State<BmiHeightScreen> createState() => _BmiHeightScreenState();
}

class _BmiHeightScreenState extends State<BmiHeightScreen> {
  int height = 170;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.white),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "What Is Your Height?",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),

          Text(
            "$height cm",
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
              onSelectedItemChanged: (v) {
                setState(() => height = v + 120);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (_, i) => Center(
                  child: Text(
                    "${i + 120}",
                    style: TextStyle(
                      color: (i + 120 == height)
                          ? Colors.white
                          : Colors.white30,
                      fontSize: (i + 120 == height) ? 28 : 20,
                    ),
                  ),
                ),
                childCount: 100,
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
                    builder: (_) => BmiResultScreen(
                      userId: widget.userId,
                      name: widget.name,
                      email: widget.email,
                      gender: widget.gender,
                      password: widget.password,
                      age: widget.age,
                      weight: widget.weight,
                      height: height,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
