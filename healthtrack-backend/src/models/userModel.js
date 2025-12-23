/**
 * 用户模型
 * 处理用户相关的数据库操作
 */

const { query, transaction } = require('../config/database');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

class UserModel {
  /**
   * 创建新用户
   */
  static async create(userData) {
    const { username, email, password, nickname, height, gender, birthday } = userData;
    const userId = uuidv4();
    const hashedPassword = await bcrypt.hash(password, 12);

    const sql = `
      INSERT INTO users (id, username, email, password, nickname, height, gender, birthday, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
    `;

    await query(sql, [
      userId,
      username,
      email,
      hashedPassword,
      nickname || username,
      height || null,
      gender || null,
      birthday || null
    ]);

    return { id: userId, username, email, nickname: nickname || username };
  }

  /**
   * 根据用户名查找用户
   */
  static async findByUsername(username) {
    const sql = 'SELECT * FROM users WHERE username = ? AND deleted_at IS NULL';
    const rows = await query(sql, [username]);
    return rows[0] || null;
  }

  /**
   * 根据邮箱查找用户
   */
  static async findByEmail(email) {
    const sql = 'SELECT * FROM users WHERE email = ? AND deleted_at IS NULL';
    const rows = await query(sql, [email]);
    return rows[0] || null;
  }

  /**
   * 根据ID查找用户
   */
  static async findById(id) {
    const sql = `
      SELECT id, username, email, nickname, avatar, height, gender, birthday, created_at
      FROM users 
      WHERE id = ? AND deleted_at IS NULL
    `;
    const rows = await query(sql, [id]);
    return rows[0] || null;
  }

  /**
   * 验证密码
   */
  static async verifyPassword(plainPassword, hashedPassword) {
    return bcrypt.compare(plainPassword, hashedPassword);
  }

  /**
   * 更新用户信息
   */
  static async update(userId, updateData) {
    const allowedFields = ['nickname', 'avatar', 'height', 'gender', 'birthday'];
    const updates = [];
    const values = [];

    for (const field of allowedFields) {
      if (updateData[field] !== undefined) {
        updates.push(`${field} = ?`);
        values.push(updateData[field]);
      }
    }

    if (updates.length === 0) {
      return false;
    }

    updates.push('updated_at = NOW()');
    values.push(userId);

    const sql = `UPDATE users SET ${updates.join(', ')} WHERE id = ?`;
    const result = await query(sql, values);
    return result.affectedRows > 0;
  }

  /**
   * 修改密码
   */
  static async updatePassword(userId, newPassword) {
    const hashedPassword = await bcrypt.hash(newPassword, 12);
    const sql = 'UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?';
    const result = await query(sql, [hashedPassword, userId]);
    return result.affectedRows > 0;
  }

  /**
   * 软删除用户
   */
  static async delete(userId) {
    const sql = 'UPDATE users SET deleted_at = NOW() WHERE id = ?';
    const result = await query(sql, [userId]);
    return result.affectedRows > 0;
  }

  /**
   * 检查用户名是否存在
   */
  static async usernameExists(username) {
    const sql = 'SELECT COUNT(*) as count FROM users WHERE username = ?';
    const rows = await query(sql, [username]);
    return rows[0].count > 0;
  }

  /**
   * 检查邮箱是否存在
   */
  static async emailExists(email) {
    const sql = 'SELECT COUNT(*) as count FROM users WHERE email = ?';
    const rows = await query(sql, [email]);
    return rows[0].count > 0;
  }
}

module.exports = UserModel;
