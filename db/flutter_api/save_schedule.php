<?php
header("Content-Type: application/json; charset=utf-8");
include "config.php"; // ใช้ config.php เพื่อความชัวร์

// เผื่อกรณี config.php ไม่ได้สร้าง conn (แต่ปกติเรามี)
if (!isset($conn)) {
    $conn = new mysqli("localhost", "root", "", "fitness_app");
    $conn->set_charset("utf8");
}

if ($conn->connect_error) {
  echo json_encode(["success"=>false,"error"=>"DB failed"]);
  exit;
}

$user_id = isset($_POST["user_id"]) ? intval($_POST["user_id"]) : 0;
$day = isset($_POST["day"]) ? $_POST["day"] : "";
$ex_json = isset($_POST["exercises"]) ? $_POST["exercises"] : "[]";
$ex = json_decode($ex_json, true);

if ($user_id <= 0 || empty($day) || !is_array($ex)) {
  echo json_encode(["success"=>false,"error"=>"Missing fields"]);
  exit;
}

// 1. ลบข้อมูลเก่าของ User ในวันนั้นๆ (เพื่อบันทึกทับ)
$del = $conn->prepare("DELETE FROM schedule WHERE user_id=? AND day=?");
$del->bind_param("is", $user_id, $day);
$del->execute();
$del->close();

// 2. เพิ่มข้อมูลใหม่
$insert = $conn->prepare("INSERT INTO schedule(user_id, day, exercise_name, exercise_type, image_url) VALUES (?,?,?,?,?)");

foreach ($ex as $item) {
  $name = isset($item["name"]) ? $item["name"] : "";
  $type = isset($item["type"]) ? $item["type"] : "";
  // รองรับทั้ง key 'image' และ 'image_url'
  $img  = isset($item["image"]) ? $item["image"] : (isset($item["image_url"]) ? $item["image_url"] : "");
  
  $insert->bind_param("issss", $user_id, $day, $name, $type, $img);
  $insert->execute();
}
$insert->close();

echo json_encode(["success"=>true]);
$conn->close();
?>