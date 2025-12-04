<?php
header("Content-Type: application/json; charset=utf-8");
$conn = new mysqli("localhost","root","","fitness_app");
if ($conn->connect_error) {
  echo json_encode([]);
  exit;
}

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
if ($user_id <= 0) {
  echo json_encode([]);
  exit;
}

// return rows with day and exercise fields
$stmt = $conn->prepare("SELECT day, exercise_name, exercise_type, image_url FROM schedule WHERE user_id=? ORDER BY id ASC");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();
$out = [];
if ($res) {
  while($r = $res->fetch_assoc()){
    $out[] = $r;
  }
}
echo json_encode($out);
$conn->close();
?>
