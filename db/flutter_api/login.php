<?php
// error_reporting(0); // เอาออก เพราะเราแก้ที่ config.php แล้ว
header("Content-Type: application/json");
include "config.php";

$response = [];

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // แก้ไขสำหรับ PHP 5.x (แทนที่ ??)
    $email = isset($_POST['email']) ? $_POST['email'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    if ($email == "" || $password == "") {
        echo json_encode(["success" => false, "message" => "Please fill in all fields"]);
        exit;
    }

    
    
    $sql = "SELECT id, name, email, gender, age, height, weight, profile_image 
            FROM users 
            WHERE email = ? AND password = ?";
            
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $email, $password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();

        // ส่งข้อมูลกลับไปตามที่ LoginScreen.dart คาดหวัง
        echo json_encode([
            "success"       => true,
            "user_id"       => $user['id'],
            "name"          => $user['name'],
            "email"         => $user['email'],
            "gender"        => $user['gender'],
            "age"           => $user['age'],
            "height"        => $user['height'],
            "weight"        => $user['weight'],
            "profile_image" => $user['profile_image']
        ]);
        
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Invalid email or password"
        ]);
    }

    $stmt->close();
    $conn->close();
}
?>