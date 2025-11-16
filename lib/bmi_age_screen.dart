import 'package:flutter/material.dart';
import 'bmi_weight_screen.dart';

class BmiAgeScreen extends StatefulWidget {
  final String userId;   
  final String name;
  final String email;
  final String gender;
  final String password;

  const BmiAgeScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.gender,
    required this.password,
  });

  @override
  State<BmiAgeScreen> createState() => _BmiAgeScreenState();
}

class _BmiAgeScreenState extends State<BmiAgeScreen> {
  int age = 20;

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
          const SizedBox(height: 20),
          const Text(
            "How Old Are You?",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),

          Text(
            "$age",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 140,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (v) {
                setState(() => age = v + 10);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (_, i) => Center(
                  child: Text(
                    "${i + 10}",
                    style: TextStyle(
                      color: (i + 10 == age) ? Colors.white : Colors.white30,
                      fontSize: (i + 10 == age) ? 28 : 20,
                    ),
                  ),
                ),
                childCount: 70,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BmiWeightScreen(
                      userId: widget.userId,
                      name: widget.name,
                      email: widget.email,
                      gender: widget.gender,
                      password: widget.password,
                      age: age,
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
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}
