import 'package:flutter/material.dart';
import '../models/answer_model.dart';
import '../services/qna_service.dart';

class CommentScreen extends StatefulWidget {
  final String questionId;
  final String userId; 
  
  const CommentScreen({super.key, required this.questionId, required this.userId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final QnAService _service = QnAService();
  final TextEditingController _controller = TextEditingController();
  List<AnswerModel> _answers = [];
  bool _isLoading = true;

  // ⚠️ แก้ URL ตรงนี้ให้ตรงกับ ngrok
  final String _imageBaseUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev/flutter_api/uploads/profile/";

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() async {
    final data = await _service.getAnswers(widget.questionId);
    setState(() {
      _answers = data;
      _isLoading = false;
    });
  }

  void _submitComment() async {
    if (_controller.text.trim().isEmpty) return;
    await _service.addAnswer(widget.questionId, widget.userId, _controller.text);
    _controller.clear();
    FocusScope.of(context).unfocus();
    _fetchComments();
  }

  // 🔥 ฟังก์ชันลบคอมเมนต์
  void _deleteComment(String answerId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ลบความคิดเห็น?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ลบ", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await _service.deleteAnswer(answerId, widget.userId);
      if (success) _fetchComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFF6A00);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ความคิดเห็น", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: orangeColor))
              : _answers.isEmpty 
                  ? const Center(child: Text("ยังไม่มีความคิดเห็น", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _answers.length,
                      itemBuilder: (context, index) {
                        final ans = _answers[index];
                        String profileUrl = "";
                        if (ans.userImage.isNotEmpty) {
                           profileUrl = "$_imageBaseUrl${ans.userImage}";
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: orangeColor,
                                    backgroundImage: profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                                    child: profileUrl.isEmpty ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(ans.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text(ans.createdAt, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                  
                                  // 🔥 ปุ่มลบ (แสดงเฉพาะเจ้าของคอมเมนต์)
                                  if (widget.userId == ans.userId)
                                     Padding(
                                       padding: const EdgeInsets.only(left: 8),
                                       child: InkWell(
                                         onTap: () => _deleteComment(ans.id),
                                         child: const Icon(Icons.close, color: Colors.white24, size: 16),
                                       ),
                                     )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 38),
                                child: Text(ans.content, style: const TextStyle(color: Colors.white70)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "เขียนความคิดเห็น...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[900],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: orangeColor,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _submitComment,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}