<?php
header("Content-Type: application/json");
include "config.php";

$userId = $_GET["user_id"];

$sql = "SELECT * FROM users WHERE id = $userId LIMIT 1";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    echo json_encode(["success" => true, "data" => $result->fetch_assoc()]);
} else {
    echo json_encode(["success" => false, "message" => "User not found"]);
}
?>
