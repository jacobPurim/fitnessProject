class QuestionModel {
  final String id;
  // ... (ตัวแปรเดิม)
  final String userId;
  final String userName;
  final String userImage;
  final String title;
  final String content;
  final String status;
  final String createdAt;
  
  int likeCount; 
  bool isLiked;
  int commentCount;

  QuestionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    this.likeCount = 0,    // Default 0
    this.isLiked = false,  // Default false
    this.commentCount = 0, // Default 0
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] ?? 'Unknown',
      userImage: json['profile_image'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      status: json['status'].toString(),
      createdAt: json['created_at'] ?? '',
      // 🔥 รับค่าจาก JSON
      likeCount: int.parse(json['like_count']?.toString() ?? '0'),
      isLiked: json['is_liked'] == true, // รับเป็น boolean
      commentCount: int.parse(json['comment_count']?.toString() ?? '0'),
    );
  }
}