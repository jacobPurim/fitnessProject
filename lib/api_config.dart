class ApiConfig {
  // ⚠️ แก้ไข IP Address ตรงนี้ที่เดียว!
  // - มือถือจริง: ใช้ IP เครื่องคอม (เช่น http://https://dermal-hae-unsteadfastly.ngrok-free.app)
  // - Emulator: ใช้ http://https://dermal-hae-unsteadfastly.ngrok-free.app (หรือ IP เครื่องคอมก็ได้ ถ้ามันมองเห็น)
  static const String baseUrl = "https://dermal-hae-unsteadfastly.ngrok-free.dev"; 
  
  // ชื่อโฟลเดอร์ API ของคุณ
  static const String apiFolder = "flutter_api";
  static const String exerciseApiFolder = "fitness_exercises_api";

  // Helper สร้าง URL เต็มๆ
  static String getUrl(String path) {
    return "$baseUrl/$apiFolder/$path";
  }
  
  static String getExerciseUrl(String path) {
    return "$baseUrl/$exerciseApiFolder/$path";
  }
}