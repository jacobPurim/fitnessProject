<?php
header("Content-Type: application/json");
include "config.php";

$id = $_POST["id"];

$sql = "DELETE FROM schedule WHERE id='$id'";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error"]);
}
?>
