import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  // 1. ข้อมูลจำลอง (สังเกตว่ารายการสุดท้าย ผมลบ imageUrl ทิ้ง เพื่อโชว์ว่ามันดึงจาก YouTube ได้เอง)
  final List<Map<String, String>> dummyNews = const [
    {
      "title": "เล่นกล้าม แต่ทำไมกล้ามไม่ขึ้น",
      "imageUrl": "",
      "category": "Workout",
      "readTime": "19 min videio",
      "url": "https://youtu.be/O0dkfFU-LwQ?si=MnpS4IgioJllSpJk"
    },
    {
      "title": "Mindset ในการลดนำ้หนั",
      "imageUrl": "",
      "category": "mindset",
      "readTime": "16 min videio",
      "url": "https://youtu.be/J3F2qe3xonM?si=ELohTGs5aGMhhlZg"
    },
    {
      "title": "whey กับ casein ต่างกันยังไง",
      "imageUrl": "",
      "category": "Technique",
      "readTime": "4 min videio",
      "url": "https://youtu.be/_7et5I0uyTE?si=oZJB6Fvc9jlS4Rc5"
    },
    {
      "title": "เทคนิคการวอร์มอัพที่ถูกต้อง ก่อนออกกำลังกาย",
      "imageUrl": "", // 
      "category": "Technique",
      "readTime": "4 min videio",
      "url": "https://youtu.be/HRRY-Gdhc0g?si=fBkN_WqahglD0aQl" 
    }
  ];

  // ฟังก์ชันช่วยดึงรูปปกจากลิงก์ YouTube
  String? _getYoutubeThumbnail(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;

      String? videoId;
      // กรณีลิงก์แบบ youtu.be/ID
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } 
      // กรณีลิงก์แบบ youtube.com/watch?v=ID
      else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
      }

      // ส่งกลับเป็นลิงก์รูปภาพคุณภาพสูง (hqdefault)
      return videoId != null ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg' : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Fitness News", style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: dummyNews.length,
        itemBuilder: (context, index) {
          final newsItem = dummyNews[index];
          return _buildNewsCard(
            context: context,
            newsItem: newsItem,
          );
        },
      ),
    );
  }

  Widget _buildNewsCard({
    required BuildContext context,
    required Map<String, String> newsItem,
  }) {
    final String title = newsItem['title']!;
    final String category = newsItem['category']!;
    final String readTime = newsItem['readTime']!;
    final String? url = newsItem['url'];
    
    //  Logic เลือกรูป: ถ้าดึงจาก YouTube ได้ ให้ใช้ ถ้าไม่ได้ ให้ใช้ imageUrl เดิม
    String displayImage = newsItem['imageUrl']!;
    if (url != null) {
      final ytThumbnail = _getYoutubeThumbnail(url);
      if (ytThumbnail != null) {
        displayImage = ytThumbnail;
      }
    }

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
          onTap: () async {
            if (url != null && url.isNotEmpty) {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot open link: $url'))
                  );
                }
              }
            }
          },
          child: SizedBox(
            height: 250,
            child: Stack(
              children: [
                // รูปภาพ
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    displayImage, // ✅ ใช้ตัวแปรที่คำนวณมา
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.redAccent),
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

                // Gradient Overlay
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

                // Play Icon (แสดงเฉพาะเมื่อเป็นลิงก์ YouTube)
                if (url != null && (url.contains('youtu.be') || url.contains('youtube.com')))
                  const Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 64),
                  ),

                // ข้อความ
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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