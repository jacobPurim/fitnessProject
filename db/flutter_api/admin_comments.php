<?php
include 'db.php';
include 'auth.php';

$question_id = isset($_GET['question_id']) ? $_GET['question_id'] : 0;

// --- Logic ลบคอมเมนต์ ---
if (isset($_GET['action']) && $_GET['action'] == 'delete_comment') {
    $ans_id = $_GET['ans_id'];
    $conn->query("DELETE FROM answers WHERE id = $ans_id");
    header("Location: admin_comments.php?question_id=$question_id"); // รีเฟรช
    exit();
}

// --- ดึงข้อมูลโพสต์หลัก (เพื่อมาโชว์หัวข้อ) ---
$q_sql = "SELECT title, content FROM questions WHERE id = $question_id";
$q_result = $conn->query($q_sql);
$question_data = $q_result->fetch_assoc();

// --- ดึงรายการคอมเมนต์ ---
$c_sql = "SELECT a.*, u.name FROM answers a JOIN users u ON a.user_id = u.id WHERE a.question_id = $question_id ORDER BY a.created_at ASC";
$comments = $conn->query($c_sql);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Comments</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background: #eee; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .post-box { background: #f9f9f9; padding: 15px; border-left: 4px solid #007bff; margin-bottom: 30px; }
        .comment-item { border-bottom: 1px solid #eee; padding: 15px 0; display: flex; justify-content: space-between; align-items: center; }
        .comment-content { flex: 1; }
        .btn-delete { background: #dc3545; color: white; text-decoration: none; padding: 5px 10px; border-radius: 4px; font-size: 0.8em; margin-left: 10px; }
        .user-name { font-weight: bold; color: #555; font-size: 0.9em; }
        .timestamp { color: #999; font-size: 0.8em; }
        .back-link { display: inline-block; margin-bottom: 15px; text-decoration: none; color: #007bff; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <a href="admin_panel.php" class="back-link">⬅️ กลับไปหน้าหลัก</a>

        <?php if($question_data): ?>
            <div class="post-box">
                <h3>📌 หัวข้อ: <?php echo htmlspecialchars($question_data['title']); ?></h3>
                <p><?php echo nl2br(htmlspecialchars($question_data['content'])); ?></p>
            </div>

            <h3>💬 ความคิดเห็น (<?php echo $comments->num_rows; ?>)</h3>
            
            <?php if($comments->num_rows > 0): ?>
                <?php while($row = $comments->fetch_assoc()): ?>
                    <div class="comment-item">
                        <div class="comment-content">
                            <div class="user-name"><?php echo htmlspecialchars($row['name']); ?> <span class="timestamp">(<?php echo $row['created_at']; ?>)</span></div>
                            <div style="margin-top:5px;"><?php echo nl2br(htmlspecialchars($row['content'])); ?></div>
                        </div>
                        <a href="?action=delete_comment&ans_id=<?php echo $row['id']; ?>&question_id=<?php echo $question_id; ?>" class="btn-delete" onclick="return confirm('ลบคอมเมนต์นี้?')">🗑️ ลบ</a>
                    </div>
                <?php endwhile; ?>
            <?php else: ?>
                <p style="color:#888;">ยังไม่มีความคิดเห็นในโพสต์นี้</p>
            <?php endif; ?>

        <?php else: ?>
            <p style="color:red;">ไม่พบโพสต์นี้ (อาจถูกลบไปแล้ว)</p>
        <?php endif; ?>
    </div>
</body>
</html>