<?php
include 'db.php';

$answer_id = $_POST['answer_id'];
$user_id   = $_POST['user_id'];

if (!$answer_id || !$user_id) {
    echo json_encode(["success" => false, "message" => "ข้อมูลไม่ครบ"]);
    exit();
}

$sql = "DELETE FROM answers WHERE id = '$answer_id' AND user_id = '$user_id'";

if ($conn->query($sql) === TRUE) {
    if ($conn->affected_rows > 0) {
        echo json_encode(["success" => true, "message" => "ลบความคิดเห็นสำเร็จ"]);
    } else {
        echo json_encode(["success" => false, "message" => "คุณไม่มีสิทธิ์ลบความคิดเห็นนี้"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
}
?>