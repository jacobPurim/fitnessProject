<?php
include "config.php";

$message = "";
// PHP 5.6 compatible: ใช้ isset แทน ??
$token = isset($_GET['token']) ? $_GET['token'] : '';

if (empty($token)) {
    $message = "❌ ไม่มีโทเคนระบุ";
} else {
    // ตรวจสอบโทเคนในฐานข้อมูล
    $checkQuery = "SELECT id FROM users WHERE reset_token = ? AND reset_token_expiry > NOW()";
    $stmt = $conn->prepare($checkQuery);
    $stmt->bind_param("s", $token);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        $message = "❌ โทเคนไม่ถูกต้องหรือหมดอายุแล้ว";
        $token = ''; // ล้างโทเคนเพื่อให้ไม่แสดงฟอร์ม
    } else {
        $message = "✅ โทเคนถูกต้อง กรุณาตั้งรหัสผ่านใหม่";
    }
    $stmt->close();
}

// ถ้ามีการส่งข้อมูลรหัสผ่านใหม่เข้ามา
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['token']) && isset($_POST['password'])) {
    $post_token = $_POST['token'];
    $new_password = $_POST['password'];

    // ตรวจสอบโทเคนอีกครั้ง
    $checkQuery = "SELECT id FROM users WHERE reset_token = ? AND reset_token_expiry > NOW()";
    $stmt = $conn->prepare($checkQuery);
    $stmt->bind_param("s", $post_token);
    $stmt->execute();
    $result = $stmt->get_result();
    
    // 🔥 แก้ไข: ทำให้ PHP 5.6 compatible (แทนที่ ?? null)
    $user_data = $result->fetch_assoc();
    $user_id = ($user_data && isset($user_data['id'])) ? $user_data['id'] : null;
    $stmt->close();
    
    if ($user_id) {
        // อัปเดตรหัสผ่านใหม่ และล้าง Token (ป้องกันการใช้ซ้ำ)
        $updateSql = "UPDATE users SET password = ?, reset_token = NULL, reset_token_expiry = NULL WHERE id = ?";
        $updateStmt = $conn->prepare($updateSql);
        $updateStmt->bind_param("si", $new_password, $user_id); 

        if ($updateStmt->execute()) {
            $message = " รหัสผ่านถูกเปลี่ยนเรียบร้อยแล้ว! สามารถเข้าสู่ระบบในแอปได้เลย";
            $token = ''; // ล้าง Token เพื่อไม่ให้แสดงฟอร์ม
        } else {
            $message = " เกิดข้อผิดพลาดในการอัปเดตรหัสผ่าน";
        }
        $updateStmt->close();
    } else {
        $message = " การรีเซ็ตล้มเหลว โทเคนไม่ถูกต้อง";
    }
    // ไม่ปิด $conn ที่นี่ เพราะอาจมีการใช้งานอื่นๆ
}
// $conn->close(); // เราจะปิด $conn ในไฟล์ config.php หรือรอให้จบการทำงานทั้งหมด

?>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รีเซ็ตรหัสผ่าน</title>
    <style>
        body { font-family: sans-serif; background-color: #f5f5f5; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); width: 350px; text-align: center; }
        h2 { color: #FF6A00; margin-bottom: 20px; }
        .message { padding: 15px; border-radius: 5px; margin-bottom: 20px; font-weight: bold; }
        .success { background-color: #e6ffe6; color: #008000; border: 1px solid #008000; }
        .error { background-color: #ffe6e6; color: #cc0000; border: 1px solid #cc0000; }
        input[type="password"] { width: 90%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px; box-sizing: border-box; font-size: 16px; }
        button { background-color: #FF6A00; color: white; padding: 12px; border: none; border-radius: 5px; cursor: pointer; width: 100%; font-size: 16px; font-weight: bold; margin-top: 15px; }
        button:hover { background-color: #e65c00; }
    </style>
    <script>
        function validateForm() {
            var password = document.getElementById("password").value;
            var confirm_password = document.getElementById("confirm_password").value;
            var msg = document.getElementById("form-message");

            if (password.length < 6) {
                msg.innerHTML = " รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
                msg.className = 'message error';
                return false;
            }
            if (password != confirm_password) {
                msg.innerHTML = " รหัสผ่านที่ยืนยันไม่ตรงกัน";
                msg.className = 'message error';
                return false;
            }
            msg.innerHTML = '';
            msg.className = 'message';
            return true;
        }
    </script>
</head>
<body>
    <div class="container">
        <h2>🔑 ตั้งรหัสผ่านใหม่</h2>
        <div id="form-message" class="message <?= strpos($message, '❌') !== false ? 'error' : 'success'; ?>">
            <?php echo $message; ?>
        </div>

        <?php if (!empty($token)): ?>
            <form method="POST" onsubmit="return validateForm()">
                <input type="hidden" name="token" value="<?php echo htmlspecialchars($token); ?>">
                
                <input type="password" id="password" name="password" placeholder="รหัสผ่านใหม่ (อย่างน้อย 6 ตัว)" required minlength="6">
                <input type="password" id="confirm_password" name="confirm_password" placeholder="ยืนยันรหัสผ่านใหม่" required minlength="6">
                
                <button type="submit">บันทึกรหัสผ่านใหม่</button>
            </form>
        <?php endif; ?>
    </div>
</body>
</html>