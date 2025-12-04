<?php
session_start();

// 🔥 แก้ไขตรงนี้: ใช้ตัวแปร PHP ($) แทนโค้ด Flutter
$admin_pass = "ZsixJacob0878892500Popo"; 

// 1. เช็คว่ามีการส่งรหัสเข้ามาไหม (กดปุ่ม Login)
if (isset($_POST['pass'])) {
    if ($_POST['pass'] === $admin_pass) {
        // รหัสถูก -> จำค่าเข้า Session
        $_SESSION['logged_in'] = true;
        
        // 🚀 สำคัญ: รีเฟรชหน้าเว็บ 1 ครั้งเพื่อเข้าสู่หน้า Admin ทันที
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    } else {
        // รหัสผิด -> เก็บข้อความแจ้งเตือน
        $error_msg = "❌ รหัสผ่านผิด! กรุณาลองใหม่";
    }
}

// 2. เช็คการ Logout
if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: " . $_SERVER['PHP_SELF']);
    exit();
}

// 3. ถ้ายังไม่ได้ Login (หรือ Login ผิด) -> โชว์ฟอร์มใส่รหัส
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Admin Login</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background: #f0f2f5; margin: 0; }
            form { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); text-align: center; width: 320px; }
            h2 { margin-top: 0; color: #333; }
            input { width: 100%; padding: 12px; margin: 15px 0; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 16px; }
            button { width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: bold; }
            button:hover { background: #0056b3; }
            .error { color: #dc3545; background: #ffe6e6; padding: 10px; border-radius: 5px; margin-bottom: 10px; font-size: 14px; }
        </style>
    </head>
    <body>
        <form method="post">
            <h2>🔐 Admin Only</h2>
            
            <?php if(isset($error_msg)) echo "<div class='error'>$error_msg</div>"; ?>
            
            <input type="password" name="pass" placeholder="ใส่รหัสผ่าน..." required autofocus>
            <button type="submit">เข้าสู่ระบบ</button>
        </form>
    </body>
    </html>
<?php
    exit(); // 🛑 หยุดโหลดเนื้อหาข้างล่าง ถ้ายังไม่ผ่านด่านนี้
}
?>