import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/qna_service.dart';
import 'add_question_screen.dart';
import 'comment_screen.dart';

class QnAScreen extends StatefulWidget {
  final String userId;
  const QnAScreen({super.key, required this.userId});

  @override
  State<QnAScreen> createState() => _QnAScreenState();
}

class _QnAScreenState extends State<QnAScreen> {
  final QnAService _service = QnAService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _service.getQuestions(widget.userId);
    setState(() {
      _questions = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Community Q&A", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6A00),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => AddQuestionScreen(userId: widget.userId))
          );
          if (result == true) _fetchData();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)))
          : _questions.isEmpty
              ? const Center(child: Text("ไม่มีข้อมูล", style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return QuestionCard(
                      question: _questions[index],
                      currentUserId: widget.userId,
                      onRefresh: _fetchData,
                    );
                  },
                ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final String currentUserId;
  final VoidCallback onRefresh;

  const QuestionCard({
    super.key, 
    required this.question, 
    required this.currentUserId,
    required this.onRefresh,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late bool isLiked;
  late int likeCount;
  final QnAService _service = QnAService();

  @override
  void initState() {
    super.initState();
    isLiked = widget.question.isLiked;
    likeCount = widget.question.likeCount;
  }

  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) likeCount++; else likeCount--;
    });
    final newCount = await _service.toggleLike(widget.currentUserId, widget.question.id);
    if (newCount != null) {
      setState(() => likeCount = newCount);
    }
  }

  // 🔥 ฟังก์ชันลบโพสต์
  void _deletePost() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ลบโพสต์?"),
        content: const Text("คุณต้องการลบโพสต์นี้ใช่ไหม?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ลบ", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await _service.deleteQuestion(widget.question.id, widget.currentUserId);
      if (success) {
        widget.onRefresh(); // รีเฟรชหน้าจอหลัก
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ลบโพสต์เรียบร้อย")));
      }
    }
  }

  void _goToComment() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => CommentScreen(
        questionId: widget.question.id, 
        userId: widget.currentUserId
      ))
    ).then((_) => widget.onRefresh());
  }

  @override
  Widget build(BuildContext context) {
    String profileUrl = ""; 
    // ⚠️ แก้ URL ตรงนี้ให้ตรงกับ ngrok ของคุณ
    if(widget.question.userImage.isNotEmpty) {
       profileUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev/flutter_api/uploads/profile/${widget.question.userImage}";
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFF6A00),
                  backgroundImage: profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                  child: profileUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.question.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(widget.question.createdAt, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
                // 🔥 ปุ่มลบ (แสดงเฉพาะเจ้าของ)
                if (widget.currentUserId == widget.question.userId)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white38),
                    onPressed: _deletePost,
                  )
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.question.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(widget.question.content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          // Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white70),
                      const SizedBox(width: 6),
                      Text("$likeCount", style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _goToComment,
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text("${widget.question.commentCount} ความคิดเห็น", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}