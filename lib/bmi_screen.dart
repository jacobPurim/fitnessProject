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
  String _detailText = ""; // เพิ่ม state สำหรับคำอธิบายรายละเอียด

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

    String status;
    Color color;
    String detail;

    // --- เกณฑ์การจำแนก BMI (WHO Standard) ---
    if (bmi < 18.5) {
      status = "น้ำหนักต่ำกว่าเกณฑ์";
      color = Colors.blue[300]!;
      detail = "คุณมีน้ำหนักน้อยกว่าปกติ ควรรับประทานอาหารให้เพียงพอและปรึกษาผู้เชี่ยวชาญด้านสุขภาพเพื่อเพิ่มน้ำหนักอย่างเหมาะสม";
    } else if (bmi < 25) {
      status = "น้ำหนักปกติ";
      color = Colors.green[400]!;
      detail = "เยี่ยมมาก! คุณมีน้ำหนักอยู่ในเกณฑ์ที่เหมาะสมและมีสุขภาพดี ควรรักษาระดับน้ำหนักนี้ไว้";
    } else if (bmi < 30) {
      status = "น้ำหนักเกิน";
      color = Colors.orange[400]!;
      detail = "คุณมีน้ำหนักเกินกว่าเกณฑ์เล็กน้อย ควรเริ่มควบคุมอาหารและออกกำลังกายเพื่อป้องกันภาวะอ้วน";
    } else if (bmi < 35) {
      status = "อ้วน ระดับ 1";
      color = Colors.deepOrange;
      detail = "คุณอยู่ในภาวะอ้วนระดับ 1 ซึ่งมีความเสี่ยงต่อโรคเรื้อรังสูงขึ้น ควรลดน้ำหนักอย่างจริงจัง";
    } else if (bmi < 40) {
      status = "อ้วน ระดับ 2";
      color = Colors.red;
      detail = "คุณอยู่ในภาวะอ้วนระดับ 2 ควรปรึกษาแพทย์หรือผู้เชี่ยวชาญด้านโภชนาการทันทีเพื่อวางแผนการลดน้ำหนักอย่างปลอดภัย";
    } else {
      status = "อ้วน ระดับ 3 (อันตรายมาก)";
      color = Colors.red[800]!;
      detail = "คุณอยู่ในภาวะอ้วนระดับ 3 ซึ่งมีความเสี่ยงสูงมากต่อภาวะแทรกซ้อนที่อันตรายต่อสุขภาพ ควรได้รับการดูแลและรักษาจากแพทย์อย่างใกล้ชิด";
    }

    setState(() {
      _bmi = bmi;
      _resultText = status;
      _resultColor = color;
      _detailText = detail;
    });
  }

  // --- UI Building Blocks ---

  // วิดเจ็ตสำหรับแสดงผลลัพธ์ (วงกลม)
  Widget _buildResultDisplay() {
    return Column(
      children: [
        SizedBox(
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
                      _resultText, // สถานะภาษาไทย
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
        ),
        const SizedBox(height: 20),
        // คำอธิบายละเอียด
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            _detailText, // รายละเอียดคำอธิบาย
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
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
                title, // ชื่อภาษาไทย
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
                    unit, // หน่วยภาษาไทย
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
        title: const Text("เครื่องคำนวณ BMI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. ผลลัพธ์และคำอธิบาย
            _buildResultDisplay(),
            
            const SizedBox(height: 30),

            // 2. Slider ส่วนสูง
            _buildSliderCard(
              title: "ส่วนสูง", // ภาษาไทย
              unit: "ซม.", // ภาษาไทย
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
              title: "น้ำหนัก", // ภาษาไทย
              unit: "กก.", // ภาษาไทย
              value: _currentWeight,
              min: 30,
              max: 150,
              onChanged: (value) {
                setState(() => _currentWeight = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}