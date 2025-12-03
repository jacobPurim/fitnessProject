import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http; // ต้อง import http
import 'dart:convert'; // ต้อง import dart:convert สำหรับ JSON

// 1. เปลี่ยนเป็น StatefulWidget
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // 2. ตัวแปรสถานะ
  List<Map<String, String>> _newsList = [];
  bool _isLoading = true;

  // 3. กำหนด URL (ใช้ฐานข้อมูลเดียวกับไฟล์อื่น ๆ)
  final String _baseUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev";
  final String _apiFolder = "flutter_api"; // หรือโฟลเดอร์ที่คุณใช้สำหรับ API

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  // 4. ฟังก์ชันสำหรับดึงข้อมูลข่าวสารจาก API
  Future<void> fetchNews() async {
    try {
      // ⚠️ สมมติว่าไฟล์ PHP อยู่ที่ /flutter_api/get_news.php
      final url = Uri.parse("$_baseUrl/$_apiFolder/get_news.php");
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (mounted) {
          setState(() {
            // แปลง List<dynamic> เป็น List<Map<String, String>>
            _newsList = data.map((item) => Map<String, String>.from(item)).toList();
            _isLoading = false;
          });
        }
      } else {
        debugPrint("Server error: ${response.statusCode}");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch news error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('ไม่สามารถเชื่อมต่อเพื่อดึงข่าวสารได้')),
        );
      }
    }
  }

  // ฟังก์ชันช่วยดึงรูปปกจากลิงก์ YouTube (เหมือนเดิม)
  String? _getYoutubeThumbnail(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;

      String? videoId;
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
      }

      return videoId != null ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg' : null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildNewsCard({
    required BuildContext context,
    required Map<String, String> newsItem,
  }) {
    final String title = newsItem['title']!;
    final String category = newsItem['category']!;
    final String readTime = newsItem['readTime']!;
    final String? url = newsItem['url'];
    
    //  Logic เลือกรูป: ถ้าดึงจาก YouTube ได้ ให้ใช้ ถ้าไม่ได้ ให้ใช้ imageUrl เดิม
    String displayImage = newsItem['imageUrl'] ?? ""; 
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
              if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                 // success
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้: $url'), backgroundColor: Colors.redAccent)
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent)) // แสดง Loading
          : _newsList.isEmpty
              ? const Center(child: Text("ไม่พบข่าวสาร", style: TextStyle(color: Colors.white70))) // แสดงเมื่อไม่มีข้อมูล
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _newsList.length,
                  itemBuilder: (context, index) {
                    final newsItem = _newsList[index];
                    return _buildNewsCard(
                      context: context,
                      newsItem: newsItem,
                    );
                  },
                ),
    );
  }
}