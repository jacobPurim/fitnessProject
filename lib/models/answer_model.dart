class AnswerModel {
  final String id;
  final String userId; // 🔥 ต้องมีตัวนี้ครับ Error ถึงจะหาย
  final String content;
  final String userName;
  final String userImage;
  final String createdAt;

  AnswerModel({
    required this.id,
    required this.userId, // 🔥 เพิ่มตรงนี้
    required this.content,
    required this.userName,
    required this.userImage,
    required this.createdAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(), // 🔥 รับค่าจาก DB ตรงนี้
      content: json['content'] ?? '',
      userName: json['user_name'] ?? 'Unknown',
      userImage: json['profile_image'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}