import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.white),
        title: const Text("Fitness News", style: TextStyle(color: Colors.white)),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _news("5 ท่าออกกำลังกายลดพุงเร็วที่สุด", "https://i.imgur.com/AtYf0Pb.jpeg"),
          _news("วิธีคุมอาหารสำหรับคนเริ่มฟิตเนส", "https://i.imgur.com/nm9G3oK.jpeg"),
          _news("ทำไมต้องเวทเทรนนิ่ง?", "https://i.imgur.com/zYVZ9zM.jpeg"),
        ],
      ),
    );
  }

  Widget _news(String title, String img) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(img, width: 120, height: 120, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}
