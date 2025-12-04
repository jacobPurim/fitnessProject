<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include "config.php";

if (!isset($_POST["user_id"])) {
    echo json_encode(["success" => false, "message" => "Missing user_id"]);
    exit();
}

$userId = $_POST["user_id"];
// ใช้ isset เช็คเพื่อป้องกัน error ใน PHP รุ่นเก่า
$name   = isset($_POST["name"]) ? $_POST["name"] : '';
$email  = isset($_POST["email"]) ? $_POST["email"] : '';
$age    = isset($_POST["age"]) ? $_POST["age"] : '';
$height = isset($_POST["height"]) ? $_POST["height"] : '';
$weight = isset($_POST["weight"]) ? $_POST["weight"] : '';
$gender = isset($_POST["gender"]) ? $_POST["gender"] : '';

$imageName = ""; // ชื่อไฟล์ที่จะบันทึกลง DB
$imagePathToReturn = ""; // ชื่อไฟล์ที่จะส่งกลับไปให้แอป

$upload_dir = "uploads/profile"; // โฟลเดอร์เก็บรูป

// ถ้ามีการอัปโหลดรูปใหม่
if (isset($_FILES["profile_image"]) && $_FILES["profile_image"]["error"] == 0) {
    
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    $ext = pathinfo($_FILES["profile_image"]["name"], PATHINFO_EXTENSION);
    $fileName = time() . "_" . rand(1000,9999) . "." . $ext;
    $targetPath = $upload_dir . "/" . $fileName;

    if (move_uploaded_file($_FILES["profile_image"]["tmp_name"], $targetPath)) {
        $imageName = $fileName; // เก็บแค่ชื่อไฟล์
        $imagePathToReturn = $fileName; 
    }
}

$sql = "UPDATE users SET 
        name='$name',
        email='$email',
        age='$age',
        height='$height',
        weight='$weight',
        gender='$gender'";

// อัปเดตรูปภาพเฉพาะเมื่อมีการอัปโหลดใหม่
if ($imageName !== "") {
    $sql .= ", profile_image='$imageName'";
}

$sql .= " WHERE id=$userId";

if ($conn->query($sql)) {
    echo json_encode([
        "success" => true, 
        "message" => "Profile updated", 
        "profile_image" => $imagePathToReturn // ส่งชื่อไฟล์ใหม่กลับไป (ถ้ามี)
    ]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
?>