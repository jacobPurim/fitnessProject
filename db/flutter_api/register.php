<?php
header("Content-Type: application/json");
include "config.php"; // ไฟล์เชื่อมต่อฐานข้อมูล

$response = [];

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // รับค่าจาก Flutter (ใช้ isset เพื่อรองรับ PHP เวอร์ชั่นเก่า)
    $name     = isset($_POST['name']) ? $_POST['name'] : '';
    $email    = isset($_POST['email']) ? $_POST['email'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';
    $gender   = isset($_POST['gender']) ? $_POST['gender'] : '';

    // 1. ตรวจว่าค่าว่างไหม
    if ($name == "" || $password == "" || $email == "") {
        echo json_encode(["success" => false, "message" => "กรุณากรอกข้อมูลให้ครบถ้วน"]);
        exit;
    }

    // ==========================================================
    // 🔥 NEW: เช็ค EMAIL ซ้ำก่อนทำอย่างอื่น (สำคัญมาก)
    // ==========================================================
    $checkQuery = "SELECT id FROM users WHERE email = ?";
    $stmtCheck = $conn->prepare($checkQuery);
    $stmtCheck->bind_param("s", $email);
    $stmtCheck->execute();
    $stmtCheck->store_result();

    if ($stmtCheck->num_rows > 0) {
        // ❌ ถ้าเจออีเมลซ้ำ ให้หยุดทันที
        echo json_encode([
            "success" => false, 
            "message" => "อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่น" // ข้อความแจ้งเตือนภาษาไทย
        ]);
        $stmtCheck->close();
        exit(); // 🛑 หยุดการทำงานตรงนี้เลย
    }
    $stmtCheck->close();
    // ==========================================================


    // =============================
    //  2. UPLOAD IMAGE (ถ้าอีเมลไม่ซ้ำ ค่อยทำส่วนนี้)
    // =============================
    $profile_image_name = ""; // default

    $upload_dir = "uploads/profile"; 

    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0777, true); 
    }

    if (isset($_FILES["profile_image"])) {
        $targetDir = $upload_dir . "/";

        // ตั้งชื่อไฟล์ใหม่ ป้องกันชื่อซ้ำ
        $fileName = time() . "_" . basename($_FILES["profile_image"]["name"]);
        $targetFilePath = $targetDir . $fileName;

        if (move_uploaded_file($_FILES["profile_image"]["tmp_name"], $targetFilePath)) {
            $profile_image_name = $fileName; // เก็บแค่ชื่อไฟล์
        } else {
             echo json_encode(["success" => false, "message" => "อัปโหลดรูปภาพไม่สำเร็จ"]);
             exit;
        }
    }

    // =============================
    //  3. INSERT DATABASE
    // =============================
    $sql = "INSERT INTO users (name, email, password, gender, profile_image)
            VALUES (?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        echo json_encode([
            "success" => false,
            "message" => "SQL Error: " . $conn->error
        ]);
        exit;
    }

    // "sssss" = 5 strings
    $stmt->bind_param("sssss", $name, $email, $password, $gender, $profile_image_name);

    if ($stmt->execute()) {
        
        // ✅ สมัครสำเร็จ
        echo json_encode([
            "success"   => true,
            "message"   => "สมัครสมาชิกสำเร็จ",
            "user_id"   => $stmt->insert_id,
            "name"      => $name,
            "email"     => $email,
            "gender"    => $gender,
            "password"  => $password, 
            "profile_image" => $profile_image_name
        ]);

    } else {
        // กรณี Error อื่นๆ
        echo json_encode([
            "success" => false,
            "message" => "เกิดข้อผิดพลาดในการบันทึก: " . $stmt->error
        ]);
    }

    $stmt->close();
    $conn->close();
}
?>