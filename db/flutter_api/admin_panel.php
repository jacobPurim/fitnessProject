<?php
include 'auth.php';  
include 'db.php';

// --- Logic จัดการ (Action) ---
if (isset($_GET['action']) && isset($_GET['id'])) {
    $id = $_GET['id'];
    
    if ($_GET['action'] == 'approve') {
        $conn->query("UPDATE questions SET status = 1 WHERE id = $id");
    } 
    elseif ($_GET['action'] == 'delete') {
        $conn->query("DELETE FROM questions WHERE id = $id");
        $conn->query("DELETE FROM question_likes WHERE question_id = $id");
        $conn->query("DELETE FROM answers WHERE question_id = $id");
    }
    
    $tab = isset($_GET['tab']) ? $_GET['tab'] : 'pending';
    header("Location: admin_panel.php?tab=$tab");
    exit();
}

// --- Logic ดึงข้อมูล (Display) ---
$tab = isset($_GET['tab']) ? $_GET['tab'] : 'pending';

if ($tab == 'approved') {
    $status_condition = "q.status = 1"; 
    $page_title = "รายการที่อนุมัติแล้ว (Live Posts)";
} else {
    $status_condition = "q.status = 0"; 
    $page_title = "รายการรออนุมัติ (Pending Requests)";
}

$sql = "SELECT q.*, u.name, 
        (SELECT COUNT(*) FROM answers WHERE question_id = q.id) as comment_count 
        FROM questions q 
        JOIN users u ON q.user_id = u.id 
        WHERE $status_condition 
        ORDER BY q.created_at DESC";
$result = $conn->query($sql);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 20px; background: #f4f6f9; color: #333; margin: 0; }
        .container { max-width: 1200px; margin: 0 auto; }
        
        /* 🔥 Header Style (จัดปุ่ม Logout ชิดขวา) */
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; background: white; padding: 15px 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .header h1 { margin: 0; font-size: 24px; }
        
        /* 🔥 ปุ่ม Logout */
        .btn-logout { 
            background: #6c757d; 
            color: white; 
            padding: 8px 15px; 
            text-decoration: none; 
            border-radius: 5px; 
            font-weight: bold; 
            font-size: 14px;
            transition: 0.2s;
        }
        .btn-logout:hover { background: #5a6268; }

        /* Tabs */
        .tabs { margin-bottom: 20px; }
        .tabs a { text-decoration: none; padding: 10px 20px; border-radius: 5px; margin-right: 5px; font-weight: bold; display: inline-block; }
        .tab-pending { background: <?php echo ($tab=='pending') ? '#007bff' : '#ddd'; ?>; color: <?php echo ($tab=='pending') ? 'white' : '#333'; ?>; }
        .tab-approved { background: <?php echo ($tab=='approved') ? '#28a745' : '#ddd'; ?>; color: <?php echo ($tab=='approved') ? 'white' : '#333'; ?>; }
        
        /* Table */
        .table-responsive { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 8px; overflow: hidden; min-width: 800px; }
        th, td { padding: 15px; border-bottom: 1px solid #eee; text-align: left; vertical-align: top; }
        th { background: #343a40; color: white; text-transform: uppercase; font-size: 0.85em; }
        tr:hover { background-color: #f1f1f1; }
        
        /* Action Buttons */
        .btn { padding: 6px 12px; text-decoration: none; color: white; border-radius: 4px; font-size: 0.9em; display: inline-block; margin-top: 2px; }
        .btn-approve { background: #28a745; }
        .btn-delete { background: #dc3545; }
        .btn-comment { background: #17a2b8; }
        
        .badge { background: #6c757d; color: white; padding: 2px 6px; border-radius: 10px; font-size: 0.8em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛠️ แผงควบคุมแอดมิน</h1>
            <a href="?logout=true" class="btn-logout" onclick="return confirm('ต้องการออกจากระบบ?')">🚪 ออกจากระบบ</a>
        </div>
        
        <div class="tabs">
            <a href="?tab=pending" class="tab-pending">⏳ รออนุมัติ</a>
            <a href="?tab=approved" class="tab-approved">✅ อนุมัติแล้ว</a>
        </div>

        <h3><?php echo $page_title; ?></h3>

        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th width="5%">ID</th>
                        <th width="15%">ผู้ใช้</th>
                        <th width="20%">หัวข้อ</th>
                        <th width="35%">เนื้อหา</th>
                        <th width="25%">จัดการ</th>
                    </tr>
                </thead>
                <tbody>
                    <?php while($row = $result->fetch_assoc()): ?>
                    <tr>
                        <td><?php echo $row['id']; ?></td>
                        <td><b><?php echo htmlspecialchars($row['name']); ?></b></td>
                        <td><?php echo htmlspecialchars($row['title']); ?></td>
                        <td><?php echo nl2br(htmlspecialchars($row['content'])); ?></td>
                        <td>
                            <?php if($tab == 'pending'): ?>
                                <a href="?action=approve&id=<?php echo $row['id']; ?>&tab=<?php echo $tab; ?>" class="btn btn-approve">✅ อนุมัติ</a>
                            <?php endif; ?>
                            
                            <a href="admin_comments.php?question_id=<?php echo $row['id']; ?>" class="btn btn-comment" target="_blank">
                                💬 คอมเมนต์ <span class="badge"><?php echo $row['comment_count']; ?></span>
                            </a>

                            <a href="?action=delete&id=<?php echo $row['id']; ?>&tab=<?php echo $tab; ?>" class="btn btn-delete" onclick="return confirm('ยืนยันลบโพสต์นี้?')">🗑️ ลบ</a>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        </div>
        
        <?php if($result->num_rows == 0) echo "<p style='text-align:center; padding: 40px; color:#888;'>ไม่มีข้อมูลในหน้านี้</p>"; ?>
    </div>
</body>
</html>