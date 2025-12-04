<?php
header("Content-Type: application/json");
include "config.php";

// ตรวจว่ามีข้อมูลส่งมาจริงไหม
if (!isset($_POST["user_id"])) {
    echo json_encode(["success" => false, "error" => "No POST received", "POST" => $_POST]);
    exit();
}

$userId = $_POST["user_id"];
$name = $_POST["name"];
$email = $_POST["email"];
$age = $_POST["age"];
$height = $_POST["height"];
$weight = $_POST["weight"];
$gender = $_POST["gender"];

$imagePath = "";

// ถ้าอัพโหลดรูปมา
if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] === 0) {

    $fileName = time() . "_" . basename($_FILES["profile_image"]["name"]);
    $targetPath = "uploads/" . $fileName;

    if (move_uploaded_file($_FILES["profile_image"]["tmp_name"], $targetPath)) {
        $imagePath = $targetPath;
    }
}

// สร้าง SQL
$sql = "UPDATE users SET 
        name='$name',
        email='$email',
        age='$age',
        height='$height',
        weight='$weight',
        gender='$gender'";

if ($imagePath != "") {
    $sql .= ", profile_image='$imagePath'";
}

$sql .= " WHERE id=$userId";

// Execute
if ($conn->query($sql)) {
    echo json_encode(["success" => true, "message" => "Updated"]);
} else {
    echo json_encode(["success" => false, "error" => $conn->error]);
}
?>
