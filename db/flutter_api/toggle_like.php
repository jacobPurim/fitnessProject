<?php
include 'db.php';

$user_id = $_POST['user_id'];
$question_id = $_POST['question_id'];

// เช็คว่าเคยไลก์ไหม
$check = $conn->query("SELECT id FROM question_likes WHERE user_id = '$user_id' AND question_id = '$question_id'");

if ($check->num_rows > 0) {
    // ถ้าเคยไลก์ -> ลบออก (Unlike)
    $conn->query("DELETE FROM question_likes WHERE user_id = '$user_id' AND question_id = '$question_id'");
    $action = "unliked";
} else {
    // ถ้าไม่เคย -> เพิ่มเข้าไป (Like)
    $conn->query("INSERT INTO question_likes (user_id, question_id) VALUES ('$user_id', '$question_id')");
    $action = "liked";
}

// ส่งจำนวนไลก์ล่าสุดกลับไป
$countResult = $conn->query("SELECT COUNT(*) as count FROM question_likes WHERE question_id = '$question_id'");
$countRow = $countResult->fetch_assoc();

echo json_encode(["success" => true, "action" => $action, "new_count" => $countRow['count']]);
?>