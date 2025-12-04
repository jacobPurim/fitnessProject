<?php
header("Content-Type: application/json");
include "config.php";

// ดึงไฟล์ PHPMailer มาใช้
require 'PHPMailer/Exception.php';
require 'PHPMailer/PHPMailer.php';
require 'PHPMailer/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

// 🔥🔥🔥 1. แก้ไขตรงนี้เป็น Ngrok URL ของคุณ (สำคัญมาก) 🔥🔥🔥
$ngrok_url = 'https://dermal-hae-unsteadfastly.ngrok-free.dev'; 
// 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    
    $email = isset($_POST['email']) ? $_POST['email'] : '';

    if ($email == "") {
        echo json_encode(["success" => false, "message" => "กรุณากรอกอีเมล"]);
        exit;
    }

    // 1. เช็คว่ามีอีเมลนี้ในระบบไหม
    $checkQuery = "SELECT id, name FROM users WHERE email = ?";
    $stmt = $conn->prepare($checkQuery);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        $userId = $user['id'];
        $userName = $user['name'];

        // 2. สร้าง Token และกำหนดเวลาหมดอายุ 1 ชั่วโมง
        $resetToken = bin2hex(random_bytes(32)); 
        $expiryTime = date("Y-m-d H:i:s", time() + 3600); 

        // 3. อัปเดต Token และเวลาหมดอายุลงฐานข้อมูล
        $updateSql = "UPDATE users SET reset_token = ?, reset_token_expiry = ? WHERE id = ?";
        $updateStmt = $conn->prepare($updateSql);
        $updateStmt->bind_param("ssi", $resetToken, $expiryTime, $userId);
        
        if ($updateStmt->execute()) {
            
            // 4. สร้าง Reset Link (ตอนนี้ลิงก์ถูกสร้างให้ถูกต้องแล้ว)
            $resetLink = $ngrok_url . "/flutter_api/reset_password_form.php?token=" . $resetToken;

            //NEW: เปิดการทำงาน PHPMailer (ปิด DEBUG MODE)//
            $mail = new PHPMailer(true);

            try {
                // Server settings (ใช้ Port 587/STARTTLS ที่เคยทำงานได้)
                $mail->isSMTP();
                $mail->Host       = 'smtp.gmail.com';
                $mail->SMTPAuth   = true;
                
                $mail->Username   = 'purim.promad@gmail.com'; 
                $mail->Password   = 'vosu pvpa tpsy mqbg'; 

                $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
                $mail->Port       = 587; 
                $mail->CharSet    = 'UTF-8';

                // เพิ่มตัวช่วยแก้ปัญหา SSL/TLS ใน XAMPP
                $mail->SMTPOptions = array(
                    'ssl' => array(
                        'verify_peer' => false,
                        'verify_peer_name' => false,
                        'allow_self_signed' => true
                    )
                );

                // Recipients (คนรับ)
                $mail->setFrom($mail->Username, 'Fitness App Support');
                $mail->addAddress($email, $userName);

                // Content (เนื้อหา)
                $mail->isHTML(true);
                $mail->Subject = 'ลิงก์สำหรับรีเซ็ตรหัสผ่าน';
                $mail->Body    = "
                    <div style='font-family: Arial, sans-serif; color: #333;'>
                        <h3>สวัสดีคุณ $userName</h3>
                        <p>คุณได้ทำการร้องขอเพื่อรีเซ็ตรหัสผ่าน กรุณาคลิกลิงก์ด้านล่างเพื่อดำเนินการต่อ</p>
                        <p>ลิงก์นี้จะหมดอายุภายใน 1 ชั่วโมง:</p>
                        
                        <a href='{$resetLink}' style='background-color: #FF6A00; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; font-weight: bold;'>
                            คลิกเพื่อรีเซ็ตรหัสผ่าน
                        </a>
                        
                        <p>หรือคัดลอกลิงก์นี้ไปวางในเบราว์เซอร์: <br> <small style='color: #888;'>{$resetLink}</small></p>
                        <br>
                        <p>ขอบคุณครับ<br>ทีมงาน Fitness App</p>
                    </div>
                ";
                $mail->AltBody = "ลิงก์รีเซ็ตรหัสผ่านของคุณ: $resetLink";

                $mail->send();
                
                echo json_encode([
                    "success" => true, 
                    "message" => "ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลเรียบร้อยแล้ว กรุณาตรวจสอบ Inbox"
                ]);

            } catch (Exception $e) {
                echo json_encode([
                    "success" => false, 
                    "message" => "ส่งอีเมลไม่สำเร็จ: {$mail->ErrorInfo}"
                ]);
            }

        } else {
            echo json_encode(["success" => false, "message" => "อัปเดตฐานข้อมูลไม่สำเร็จ"]);
        }

    } else {
        // ไม่เจออีเมลในระบบ
        echo json_encode(["success" => false, "message" => "ไม่พบอีเมลนี้ในระบบ"]);
    }

    $conn->close();
}