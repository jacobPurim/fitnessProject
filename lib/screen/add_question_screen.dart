import 'package:KaitomGym/services/qna_service.dart';
import 'package:flutter/material.dart';
import '../services/qna_service.dart';

class AddQuestionScreen extends StatefulWidget {
  final String userId;
  const AddQuestionScreen({super.key, required this.userId});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final QnAService _service = QnAService();
  bool _isLoading = false;

  void _submit() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    bool success = await _service.addQuestion(
      widget.userId,
      _titleController.text,
      _contentController.text,
    );

    setState(() => _isLoading = false);
    if (success && mounted) {
      // แจ้งเตือนว่าต้องรออนุมัติ
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("สำเร็จ"),
          content: const Text("ส่งคำถามเรียบร้อยแล้ว กรุณารอแอดมินอนุมัติก่อนแสดงผล"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // ปิด Dialog
                Navigator.pop(context, true); // กลับไปหน้า Q&A
              },
              child: const Text("ตกลง"),
            )
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("เกิดข้อผิดพลาด")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ตั้งคำถามใหม่", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "หัวข้อคำถาม...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true, fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "รายละเอียด...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true, fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ส่งคำถาม", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}