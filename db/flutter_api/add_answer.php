<?php
include 'db.php';

$question_id = $_POST['question_id'];
$user_id     = $_POST['user_id'];
$content     = $_POST['content'];

if(!$question_id || !$user_id || !$content) {
    echo json_encode(["success" => false, "message" => "ข้อมูลไม่ครบ"]);
    exit();
}

$sql = "INSERT INTO answers (question_id, user_id, content) VALUES ('$question_id', '$user_id', '$content')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false]);
}
?>