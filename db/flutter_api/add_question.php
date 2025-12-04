<?php
include 'db.php';

$user_id = $_POST['user_id'];
$title   = $_POST['title'];
$content = $_POST['content'];

if (!$user_id || !$title || !$content) {
    echo json_encode(["success" => false, "message" => "ข้อมูลไม่ครบ"]);
    exit();
}

// status เริ่มต้นเป็น 0 (รออนุมัติ)
$sql = "INSERT INTO questions (user_id, title, content, status) VALUES ('$user_id', '$title', '$content', 0)";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "ส่งคำถามเรียบร้อย รอการตรวจสอบ"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
}
?>