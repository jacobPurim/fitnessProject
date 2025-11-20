import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async'; // Import Timer

class ExerciseVideoScreen extends StatefulWidget {
  final String name;
  final String videoUrl;

  const ExerciseVideoScreen({
    super.key,
    required this.name,
    required this.videoUrl,
  });

  @override
  State<ExerciseVideoScreen> createState() => _ExerciseVideoScreenState();
}

class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _controlsVisible = true;
  bool _isMuted = false;
  Timer? _hideControlsTimer;
  
  // 1. สร้างฟังก์ชัน listener แยกออกมา
  void _videoListener() {
    // 2. ตรวจสอบ mounted ก่อน setState
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // 1. ใช้วิธีใหม่ในการ initialize (รองรับ Uri)
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // 3. ตรวจสอบ mounted ก่อน setState ใน .then()
        if (!mounted) return;

        // เมื่อโหลดเสร็จ
        setState(() => _isLoading = false);
        _controller.play(); // เริ่มเล่น
        _controller.setLooping(true); // ตั้งค่าวิดีโอให้วนลูป
        _startHideControlsTimer(); // เริ่มจับเวลาซ่อน UI
      });

    // 2. เพิ่ม Listener เพื่อให้ UI อัปเดตตาม (เช่น ไอคอน play/pause)
    _controller.addListener(_videoListener); // 4. ใช้ฟังก์ชันที่แยกออกมา
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener); // 5. ถอด listener ออกตอน dispose
    _controller.dispose();
    _hideControlsTimer?.cancel(); // ยกเลิก Timer
    super.dispose();
  }

  // --- 3. ฟังก์ชันควบคุมการทำงาน ---

  // ฟังก์ชันสลับการซ่อน/แสดง UI ควบคุม
  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _startHideControlsTimer(); // ถ้าเปิด UI ให้เริ่มนับถอยหลังเพื่อซ่อน
      } else {
        _hideControlsTimer?.cancel(); // ถ้าผู้ใช้กดซ่อนเอง ให้ยกเลิก Timer
      }
    });
  }

  // ฟังก์ชันเริ่มนับถอยหลัง 3 วินาที เพื่อซ่อน UI
  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel(); // ยกเลิกอันเก่า (ถ้ามี)
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      // 6. ตรวจสอบ mounted ก่อน setState ใน Timer
      if (!mounted) return;
      if (_controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  // ฟังก์ชันสลับ เล่น/หยุด
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _hideControlsTimer?.cancel(); // หยุดเล่น -> ไม่ต้องซ่อน UI
      } else {
        _controller.play();
        _startHideControlsTimer(); // เริ่มเล่น -> ซ่อน UI
      }
    });
  }

  // ฟังก์ชันสลับ ปิด/เปิด เสียง
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  // ฟังก์ชันแปลง Duration เป็น String (เช่น 01:30)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // --- 4. Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // ทำให้กลืนไปกับพื้นหลัง
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.redAccent)
            : _buildPlayerStack(), // 5. แยกวิดเจ็ต Player Stack
      ),
    );
  }

  // วิดเจ็ตหลักที่รวม วิดีโอ + UI ควบคุม
  Widget _buildPlayerStack() {
    // ใช้ AspectRatio เพื่อให้วิดีโอคงสัดส่วนเดิม
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 6. ตัวเล่นวิดีโอ
          VideoPlayer(_controller),

          // 7. ตัวจับการแตะเพื่อซ่อน/แสดง UI
          // (วางทับบนวิดีโอ)
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque, // ทำให้พื้นที่ว่างๆ ก็แตะได้
            child: Container(), // Container ว่างๆ
          ),

          // 8. UI ควบคุม (ที่จะ ซ่อน/แสดง)
          AnimatedOpacity(
            opacity: _controlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            // ป้องกันการกดโดนปุ่มที่มองไม่เห็น
            child: AbsorbPointer(
              absorbing: !_controlsVisible,
              child: _buildControlsOverlay(),
            ),
          ),
        ],
      ),
    );
  }

  // วิดเจ็ต UI ควบคุมทั้งหมด
  Widget _buildControlsOverlay() {
    return Container(
      // 9. พื้นหลังสีดำโปร่งแสง
      color: Colors.black.withOpacity(0.35),
      child: Stack(
        children: [
          // 10. ปุ่ม เล่น/หยุด ตรงกลาง
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _togglePlayPause,
                iconSize: 50,
                color: Colors.white,
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ),
          ),

          // 11. แถบควบคุมด้านล่าง
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: Colors.black.withOpacity(0.6),
              child: Row(
                children: [
                  // เวลาที่เล่น
                  Text(
                    _formatDuration(_controller.value.position),
                    style: const TextStyle(color: Colors.white),
                  ),
                  // แถบ Progress Bar
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true, // อนุญาตให้ลาก
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      colors: const VideoProgressColors(
                        playedColor: Colors.redAccent, // สีที่เล่นแล้ว
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white30,
                      ),
                    ),
                  ),
                  // เวลาทั้งหมด
                  Text(
                    _formatDuration(_controller.value.duration),
                    style: const TextStyle(color: Colors.white),
                  ),
                  // ปุ่ม Mute
                  IconButton(
                    onPressed: _toggleMute,
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}