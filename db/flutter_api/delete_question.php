<?php
include 'db.php';

$question_id = $_POST['question_id'];
$user_id     = $_POST['user_id']; // ID ของคนที่จะลบ

if (!$question_id || !$user_id) {
    echo json_encode(["success" => false, "message" => "ข้อมูลไม่ครบ"]);
    exit();
}

// 1. ลบคำถาม โดยต้องเป็นเจ้าของเท่านั้น (WHERE user_id = $user_id)
// หมายเหตุ: ถ้าต้องการให้ Admin ลบได้ด้วย ต้องเพิ่มเงื่อนไขเช็ค Role ตรงนี้
$sql = "DELETE FROM questions WHERE id = '$question_id' AND user_id = '$user_id'";

if ($conn->query($sql) === TRUE) {
    if ($conn->affected_rows > 0) {
        // ลบข้อมูลที่เกี่ยวข้อง (Likes & Answers) เพื่อไม่ให้รก Database
        $conn->query("DELETE FROM question_likes WHERE question_id = '$question_id'");
        $conn->query("DELETE FROM answers WHERE question_id = '$question_id'");
        
        echo json_encode(["success" => true, "message" => "ลบโพสต์สำเร็จ"]);
    } else {
        echo json_encode(["success" => false, "message" => "คุณไม่มีสิทธิ์ลบโพสต์นี้ หรือโพสต์ไม่ถูกพบ"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
}
?>