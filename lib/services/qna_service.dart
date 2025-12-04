import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';
import '../models/answer_model.dart';

class QnAService {
  // ⚠️ แก้ URL ให้ตรงกับ ngrok ของคุณ
  final String baseUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev/flutter_api";

  Future<List<QuestionModel>> getQuestions(String currentUserId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_questions.php?user_id=$currentUserId"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => QuestionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error getQuestions: $e");
      return [];
    }
  }

  Future<int?> toggleLike(String userId, String questionId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/toggle_like.php"),
        body: {"user_id": userId, "question_id": questionId},
      );
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return int.parse(data['new_count'].toString());
      }
    } catch (e) {
      print("Error toggleLike: $e");
    }
    return null;
  }

  Future<List<AnswerModel>> getAnswers(String questionId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_answers.php?question_id=$questionId"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AnswerModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addAnswer(String questionId, String userId, String content) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_answer.php"),
        body: {"question_id": questionId, "user_id": userId, "content": content},
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addQuestion(String userId, String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_question.php"),
        body: {"user_id": userId, "title": title, "content": content},
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // 🔥 ฟังก์ชันลบคำถาม (เพิ่มใหม่)
  Future<bool> deleteQuestion(String questionId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete_question.php"),
        body: {"question_id": questionId, "user_id": userId},
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // 🔥 ฟังก์ชันลบคอมเมนต์ (เพิ่มใหม่)
  Future<bool> deleteAnswer(String answerId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete_answer.php"),
        body: {"answer_id": answerId, "user_id": userId},
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}