<?php
include 'db.php';

$current_user_id = isset($_GET['user_id']) ? $_GET['user_id'] : 0;

// Query นี้จะดึงข้อมูลคำถาม + จำนวนไลก์ทั้งหมด + เช็คว่า user คนนี้ไลก์หรือยัง (is_liked)
$sql = "SELECT q.*, 
               u.name as user_name, 
               u.profile_image,
               (SELECT COUNT(*) FROM question_likes WHERE question_id = q.id) as like_count,
               (SELECT COUNT(*) FROM question_likes WHERE question_id = q.id AND user_id = '$current_user_id') as is_liked,
               (SELECT COUNT(*) FROM answers WHERE question_id = q.id) as comment_count
        FROM questions q 
        JOIN users u ON q.user_id = u.id 
        WHERE q.status = 1 
        ORDER BY q.created_at DESC";

$result = $conn->query($sql);
$questions = array();

while($row = $result->fetch_assoc()) {
    // แปลง is_liked ให้เป็น true/false เพื่อให้ง่ายต่อ Flutter
    $row['is_liked'] = $row['is_liked'] > 0;
    $questions[] = $row;
}

echo json_encode($questions);
?>