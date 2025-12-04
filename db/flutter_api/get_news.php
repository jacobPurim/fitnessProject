<?php
// กำหนด Header ให้เป็น JSON เพื่อให้ Flutter ทราบว่าข้อมูลที่ส่งกลับมาเป็น JSON
header("Content-Type: application/json; charset=utf-8");

// 1. ข้อมูลข่าวสาร (ใช้ข้อมูลที่คุณให้มา)
// ถ้าจะการดึงข้อมูลจาก Database จริง ๆ ในอนาคต ต้องเปลี่ยนโค้ดส่วนนี้เป็นการเชื่อมต่อฐานข้อมูล ใช้ xampp
$news = [
    [
        "title" => "เล่นกล้าม แต่ทำไมกล้ามไม่ขึ้น",
        "imageUrl" => "",
        "category" => "การออกกำลัง",
        "readTime" => "19 นาที",
        "url" => "https://youtu.be/O0dkfFU-LwQ?si=MnpS4IgioJllSpJk"
    ],
    [
        "title" => "Mindset ในการลดนำ้หนั",
        "imageUrl" => "",
        "category" => "mindset",
        "readTime" => "16 นาที",
        "url" => "https://youtu.be/J3F2qe3xonM?si=ELohTGs5aGMhhlZg"
    ],
    [
        "title" => "whey กับ casein ต่างกันยังไง",
        "imageUrl" => "",
        "category" => "Technique",
        "readTime" => "4 นาที",
        "url" => "https://youtu.be/_7et5I0uyTE?si=oZJB6Fvc9jlS4Rc5"
    ],
    [
        "title" => "เทคนิคการวอร์มอัพที่ถูกต้อง ก่อนออกกำลังกาย",
        "imageUrl" => "",
        "category" => "Technique",
        "readTime" => "4 นาที",
        "url" => "https://youtu.be/HRRY-Gdhc0g?si=fBkN_WqahglD0aQl"
    ]
];

// 2. แปลง PHP Array ให้เป็น JSON และส่งกลับ
echo json_encode($news, JSON_UNESCAPED_UNICODE);

?>