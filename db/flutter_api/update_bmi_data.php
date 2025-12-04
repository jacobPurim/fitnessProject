<?php
header("Content-Type: application/json");
include "config.php";

// รับค่า (ใช้ isset() เพื่อ PHP 5.x)
$userId = isset($_POST['user_id']) ? $_POST['user_id'] : 0;
$age    = isset($_POST['age']) ? $_POST['age'] : 0;
$height = isset($_POST['height']) ? $_POST['height'] : 0.0;
$weight = isset($_POST['weight']) ? $_POST['weight'] : 0.0;

if (empty($userId)) {
    echo json_encode(["success" => false, "message" => "Missing user_id"]);
    exit;
}

$sql = "UPDATE users SET age = ?, height = ?, weight = ? WHERE id = ?";

$stmt = $conn->prepare($sql);

// d = double (for decimal), i = integer
// SQL: age(i), height(d), weight(d), id(i)
$stmt->bind_param("iddi", $age, $height, $weight, $userId); 

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "BMI data saved"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to save BMI data: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>