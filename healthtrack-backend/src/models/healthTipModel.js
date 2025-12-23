/**
 * 健康百科模型
 */

const { query } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class HealthTipModel {
  /**
   * 获取所有健康知识
   */
  static async findAll(options = {}) {
    const { category, limit = 50, offset = 0 } = options;
    let sql = 'SELECT * FROM health_tips WHERE is_active = 1';
    const params = [];

    if (category) {
      sql += ' AND category = ?';
      params.push(category);
    }

    sql += ' ORDER BY sort_order ASC, created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return query(sql, params);
  }

  /**
   * 获取所有分类
   */
  static async getCategories() {
    const sql = 'SELECT DISTINCT category FROM health_tips WHERE is_active = 1 ORDER BY category';
    return query(sql);
  }

  /**
   * 根据ID获取详情
   */
  static async findById(id) {
    const sql = 'SELECT * FROM health_tips WHERE id = ?';
    const rows = await query(sql, [id]);
    return rows[0] || null;
  }

  /**
   * 创建健康知识（管理员）
   */
  static async create(tipData) {
    const id = uuidv4();
    const sql = `
      INSERT INTO health_tips (id, title, content, category, image_url, sort_order, is_active, created_at)
      VALUES (?, ?, ?, ?, ?, ?, 1, NOW())
    `;
    await query(sql, [
      id,
      tipData.title,
      tipData.content,
      tipData.category,
      tipData.imageUrl || null,
      tipData.sortOrder || 0
    ]);
    return { id, ...tipData };
  }
}

module.exports = HealthTipModel;
