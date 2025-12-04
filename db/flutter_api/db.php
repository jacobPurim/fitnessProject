<?php
$host = "localhost";
$user = "root";
$pass = "";
$db = "fitness_app"; // ชื่อ Database ของคุณ

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// บรรทัดนี้สำคัญ เพื่อให้ภาษาไทยไม่เพี้ยน
$conn->set_charset("utf8");
?>