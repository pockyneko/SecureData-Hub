// 受保护的私有数据接口
const express = require('express');
const mysql = require('mysql2/promise');
const authenticateToken = require('../middleware/auth');
const router = express.Router();

// 数据库连接池
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// 获取当前用户的私有数据
router.get('/private', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const [rows] = await pool.query('SELECT id, content, created_at FROM PrivateData WHERE user_id = ?', [userId]);
    res.json({ data: rows });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
});

module.exports = router;
