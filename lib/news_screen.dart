import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- 1. Import (สำคัญ)

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  // 1. สร้าง Data Model (จำลอง)
  final List<Map<String, String>> dummyNews = const [
    {
      "title": "5 ท่าออกกำลังกายลดพุงเร็วที่สุด",
      "imageUrl": "https://i.imgur.com/AtYf0Pb.jpeg",
      "category": "Workout",
      "readTime": "7 min read",
      "url": "https://www.google.com/search?q=ท่าออกกำลังกายลดพุง" // <-- (ตัวอย่าง)
    },
    {
      "title": "วิธีคุมอาหารสำหรับคนเริ่มฟิตเนส",
      "imageUrl": "https://i.imgur.com/nm9G3oK.jpeg",
      "category": "Nutrition",
      "readTime": "5 min read",
      "url": "https://www.google.com/search?q=วิธีคุมอาหาร" // <-- (ตัวอย่าง)
    },
    {
      "title": "ทำไมต้องเวทเทรนนิ่ง? ประโยชน์ที่คุณอาจไม่รู้",
      "imageUrl": "https://i.imgur.com/zYVZ9zM.jpeg",
      "category": "Mindset",
      "readTime": "3 min read",
      "url": "https://www.google.com/search?q=ประโยชน์เวทเทรนนิ่ง" // <-- (ตัวอย่าง)
    },
     {
      "title": "เทคนิคการวอร์มอัพที่ถูกต้อง ก่อนออกกำลังกาย",
      "imageUrl": "https://images.pexels.com/photos/949126/pexels-photo-949126.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "category": "Technique",
      "readTime": "4 min read",
      "url": "https://youtu.be/HRRY-Gdhc0g?si=fBkN_WqahglD0aQl" // <-- 2. ใส่ลิงก์ของคุณ
    } 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text("Fitness News", style: TextStyle(color: Colors.white)),
      ),

      // 2. ใช้ ListView.builder
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: dummyNews.length,
        itemBuilder: (context, index) {
          final newsItem = dummyNews[index];
          // 3. ส่ง newsItem ไปทั้งก้อน (เหมือนเดิม)
          return _buildNewsCard(
            context: context,
            newsItem: newsItem,
          );
        },
      ),
    );
  }

  // 4. Widget Card
  Widget _buildNewsCard({
    required BuildContext context,
    required Map<String, String> newsItem, // 5. รับเป็น Map
  }) {
    // 6. แตกข้อมูลออกมา
    final String title = newsItem['title']!;
    final String imageUrl = newsItem['imageUrl']!;
    final String category = newsItem['category']!;
    final String readTime = newsItem['readTime']!;
    final String? url = newsItem['url']; // <-- 7. ดึง URL ออกมา

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        color: Colors.grey[900],
        elevation: 4,
        clipBehavior: Clip.antiAlias, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          // 8. OnTap (แก้ไขใหม่)
          onTap: () async {
            // ตรวจสอบว่า url มีค่าหรือไม่
            if (url != null && url.isNotEmpty) {
              final Uri uri = Uri.parse(url);
              // พยายามเปิดลิงก์
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication); // เปิดแอปภายนอก (เช่น YouTube, Chrome)
              } else {
                // ถ้าเปิดไม่ได้ (เช่น ลิงก์ผิด)
                print("Could not launch $url");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot open link: $url'))
                );
              }
            } else {
              print("No URL for '$title'");
            }
          },
          child: Container(
            height: 250, 
            child: Stack(
              children: [
                // ( ... โค้ดส่วน UI รูปภาพ ... )
                // 7. รูปภาพ (อยู่ล่างสุด)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover, 
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                ),

                // 10. Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9), 
                        Colors.black.withOpacity(0.0), 
                      ],
                      stops: const [0.0, 0.7], 
                    ),
                  ),
                ),

                // 11. ข้อความ (อยู่บนสุด)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 12. "ป้าย" Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 13. Title (หัวข้อข่าว)
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 14. Read Time (เวลาอ่าน)
                      Text(
                        readTime,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}