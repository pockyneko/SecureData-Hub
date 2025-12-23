// 用户注册和登录相关路由
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2/promise');
const router = express.Router();

// 数据库连接池
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// 注册接口
router.post('/register', async (req, res) => {
  const { username, password, email } = req.body;
  if (!username || !password || !email) {
    return res.status(400).json({ message: '缺少必要字段' });
  }
  try {
    const [rows] = await pool.query('SELECT id FROM User WHERE username = ? OR email = ?', [username, email]);
    if (rows.length > 0) {
      return res.status(409).json({ message: '用户名或邮箱已存在' });
    }
    const password_hash = await bcrypt.hash(password, 10);
    await pool.query('INSERT INTO User (username, password_hash, email) VALUES (?, ?, ?)', [username, password_hash, email]);
    res.status(201).json({ message: '注册成功' });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
});

// 登录接口
router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ message: '缺少用户名或密码' });
  }
  try {
    const [rows] = await pool.query('SELECT * FROM User WHERE username = ?', [username]);
    if (rows.length === 0) {
      return res.status(401).json({ message: '用户名或密码错误' });
    }
    const user = rows[0];
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ message: '用户名或密码错误' });
    }
    const token = jwt.sign({ id: user.id, username: user.username }, process.env.JWT_SECRET, { expiresIn: '2h' });
    res.json({ token });
  } catch (err) {
    res.status(500).json({ message: '服务器错误', error: err.message });
  }
});

module.exports = router;
