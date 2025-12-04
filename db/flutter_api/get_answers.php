<?php
include 'db.php';

$question_id = $_GET['question_id'];

$sql = "SELECT a.*, u.name as user_name, u.profile_image 
        FROM answers a 
        JOIN users u ON a.user_id = u.id 
        WHERE a.question_id = '$question_id' 
        ORDER BY a.created_at ASC";

$result = $conn->query($sql);
$answers = array();

while($row = $result->fetch_assoc()) {
    $answers[] = $row;
}

echo json_encode($answers);
?>