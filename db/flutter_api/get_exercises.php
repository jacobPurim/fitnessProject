<?php
// 1. ปิดการแสดง Error/Warning ของ PHP (สำคัญมาก!)
error_reporting(0); 
ini_set('display_errors', 0);

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

$host = "localhost";
$user = "root";
$pass = "";
$db   = "fitness_app"; 

$conn = new mysqli($host, $user, $pass, $db);
mysqli_set_charset($conn, "utf8");

// ถ้าต่อ DB ไม่ติด ให้ส่ง JSON บอก Error แทนการตายไปเฉยๆ
if ($conn->connect_error) {
    echo json_encode(["error" => "DB connect failed: " . $conn->connect_error]);
    exit;
}

$sql = "SELECT * FROM exercises"; 
$result = $conn->query($sql);

$data = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {

        // แก้ URL รูปภาพ (IP เครื่องคอมคุณ)
        if (!empty($row["image_url"])) {
            if (strpos($row["image_url"], "http") === false) {
                // ตรวจสอบว่าต้องเติม uploads/ หรือไม่
                $prefix = (strpos($row["image_url"], "uploads/") === 0) ? "" : "uploads/";
                $row["image_url"] = "https://dermal-hae-unsteadfastly.ngrok-free.dev/fitness_exercises_api/" . $prefix . $row["image_url"];
            }
        }

        // แก้ URL วิดีโอ (ถ้ามี)
        if (!empty($row["video_url"])) {
             if (strpos($row["video_url"], "http") === false) {
                $prefix = (strpos($row["video_url"], "uploads/") === 0) ? "" : "uploads/";
                $row["video_url"] = "https://dermal-hae-unsteadfastly.ngrok-free.dev/fitness_exercises_api/" . $prefix . $row["video_url"];
             }
        }

        $data[] = $row;
    }
}

// ส่ง JSON กลับไป
echo json_encode($data, JSON_UNESCAPED_UNICODE);
$conn->close();
?>