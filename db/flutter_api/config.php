<?php
// กำหนดข้อมูลการเชื่อมต่อฐานข้อมูล
$host = "localhost";
$user = "root";
$pass = "";
$db = "fitness_app"; 

// สร้างการเชื่อมต่อ (ใช้ตัวแปรใหม่ตามที่ผู้ใช้กำหนด)
$conn = new mysqli($host, $user, $pass, $db);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$conn->set_charset("utf8");

