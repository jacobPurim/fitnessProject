import 'package:flutter/material.dart';
import 'dart:math';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  // เปลี่ยนจาก Controllers มาใช้ค่า state สำหรับ Slider
  double _currentHeight = 170;
  double _currentWeight = 70;

  double _bmi = 0;
  String _resultText = "";
  Color _resultColor = Colors.green; // สีเริ่มต้น

  @override
  void initState() {
    super.initState();
    // คำนวณ BMI ตั้งต้นเมื่อเปิดหน้า
    _calculateBMI();
  }

  // ฟังก์ชันคำนวณและอัปเดตสถานะ
  void _calculateBMI() {
    if (_currentHeight <= 0) return;

    final double heightInMeters = _currentHeight / 100;
    final double bmi = _currentWeight / (heightInMeters * heightInMeters);

    setState(() {
      _bmi = bmi;
      if (bmi < 18.5) {
        _resultText = "Underweight";
        _resultColor = Colors.blue[300]!;
      } else if (bmi < 25) {
        _resultText = "Normal";
        _resultColor = Colors.green[400]!;
      } else if (bmi < 30) {
        _resultText = "Overweight";
        _resultColor = Colors.orange[400]!;
      } else {
        _resultText = "Obesity";
        _resultColor = Colors.red[400]!;
      }
    });
  }

  // --- UI Building Blocks ---

  // วิดเจ็ตสำหรับแสดงผลลัพธ์ (วงกลม)
  Widget _buildResultDisplay() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // วงกลมพื้นหลัง
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[900],
              border: Border.all(
                color: _resultColor,
                width: 12,
              ),
              boxShadow: [
                BoxShadow(
                  color: _resultColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
          ),
          // ข้อความแสดงผล
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _bmi.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "BMI",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _resultColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _resultText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // วิดเจ็ตสำหรับการ์ด Slider (ใช้ซ้ำ)
  Widget _buildSliderCard({
    required String title,
    required String unit,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[400], fontSize: 18),
              ),
              Row(
                children: [
                  Text(
                    value.round().toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8.0,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: Colors.redAccent,
              inactiveTrackColor: Colors.grey[700],
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              thumbColor: Colors.redAccent,
              overlayColor: Colors.redAccent.withAlpha(32),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(), // แบ่งช่องตามจำนวนเต็ม
              label: value.round().toString(),
              onChanged: (newValue) {
                onChanged(newValue);
                _calculateBMI(); // คำนวณใหม่ทุกครั้งที่ลาก
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("BMI Calculator", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. ผลลัพธ์ (ย้ายมาไว้ข้างบน)
            _buildResultDisplay(),
            
            const SizedBox(height: 30),

            // 2. Slider ส่วนสูง
            _buildSliderCard(
              title: "Height",
              unit: "cm",
              value: _currentHeight,
              min: 100,
              max: 220,
              onChanged: (value) {
                setState(() => _currentHeight = value);
              },
            ),

            const SizedBox(height: 20),

            // 3. Slider น้ำหนัก
            _buildSliderCard(
              title: "Weight",
              unit: "kg",
              value: _currentWeight,
              min: 30,
              max: 150,
              onChanged: (value) {
                setState(() => _currentWeight = value);
              },
            ),

            // ไม่ต้องมีปุ่ม "Calculate" เพราะมันคำนวณสด
          ],
        ),
      ),
    );
  }
}