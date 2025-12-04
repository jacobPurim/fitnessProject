<?php
header("Content-Type: application/json");
include "config.php";

$user_id = $_POST["user_id"] ?? null;
$day = $_POST["day"] ?? null;
$exercise_id = $_POST["exercise_id"] ?? null;

if (!$user_id || !$day || !$exercise_id) {
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit;
}

$sql = "INSERT INTO schedule (user_id, day, exercise_id) VALUES ('$user_id', '$day', '$exercise_id')";
if ($conn->query($sql)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
?>
