import 'package:flutter/material.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  double? _bmi;
  String _resultText = "";

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null || height == 0) {
      setState(() {
        _resultText = "Please enter valid numbers";
      });
      return;
    }

    final bmi = weight / ((height / 100) * (height / 100));

    setState(() {
      _bmi = bmi;

      if (bmi < 18.5) {
        _resultText = "Underweight";
      } else if (bmi < 25) {
        _resultText = "Normal weight";
      } else if (bmi < 30) {
        _resultText = "Overweight";
      } else {
        _resultText = "Obesity";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("BMI Calculator", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Weight (kg)",
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _heightController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Height (cm)",
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: const Text("Calculate BMI", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 30),

            if (_bmi != null)
              Column(
                children: [
                  Text(
                    "BMI: ${_bmi!.toStringAsFixed(1)}",
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _resultText,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 20),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
