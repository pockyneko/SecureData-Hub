/**
 * 健康记录模型
 * 处理健康数据相关的数据库操作
 */

const { query, transaction } = require('../config/database');
const { v4: uuidv4 } = require('uuid');
const moment = require('moment');

class HealthRecordModel {
  /**
   * 创建健康记录
   */
  static async create(recordData) {
    const { userId, type, value, note, recordDate } = recordData;
    const id = uuidv4();
    const date = recordDate || moment().format('YYYY-MM-DD');

    const sql = `
      INSERT INTO health_records (id, user_id, type, value, note, record_date, created_at)
      VALUES (?, ?, ?, ?, ?, ?, NOW())
    `;

    await query(sql, [id, userId, type, value, note || null, date]);
    return { id, userId, type, value, note, recordDate: date };
  }

  /**
   * 批量创建健康记录
   */
  static async createMany(records) {
    const values = records.map(r => [
      uuidv4(),
      r.userId,
      r.type,
      r.value,
      r.note || null,
      r.recordDate || moment().format('YYYY-MM-DD')
    ]);

    const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
    const flatValues = values.flat();

    const sql = `
      INSERT INTO health_records (id, user_id, type, value, note, record_date)
      VALUES ${placeholders}
    `;

    await query(sql, flatValues);
    return values.length;
  }

  /**
   * 获取用户的健康记录
   */
  static async findByUserId(userId, options = {}) {
    const { type, startDate, endDate, limit = 100, offset = 0 } = options;
    let sql = `
      SELECT id, type, value, note, record_date, created_at
      FROM health_records
      WHERE user_id = ?
    `;
    const params = [userId];

    if (type) {
      sql += ' AND type = ?';
      params.push(type);
    }

    if (startDate) {
      sql += ' AND record_date >= ?';
      params.push(startDate);
    }

    if (endDate) {
      sql += ' AND record_date <= ?';
      params.push(endDate);
    }

    sql += ' ORDER BY record_date DESC, created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return query(sql, params);
  }

  /**
   * 获取指定日期范围内的统计数据
   */
  static async getStatistics(userId, type, startDate, endDate) {
    const sql = `
      SELECT 
        type,
        COUNT(*) as count,
        AVG(value) as avg_value,
        MIN(value) as min_value,
        MAX(value) as max_value,
        SUM(value) as total_value
      FROM health_records
      WHERE user_id = ? AND type = ? AND record_date BETWEEN ? AND ?
      GROUP BY type
    `;

    const rows = await query(sql, [userId, type, startDate, endDate]);
    return rows[0] || null;
  }

  /**
   * 获取每日汇总数据
   */
  static async getDailySummary(userId, startDate, endDate) {
    const sql = `
      SELECT 
        record_date,
        type,
        AVG(value) as avg_value,
        SUM(value) as total_value,
        COUNT(*) as count
      FROM health_records
      WHERE user_id = ? AND record_date BETWEEN ? AND ?
      GROUP BY record_date, type
      ORDER BY record_date ASC
    `;

    return query(sql, [userId, startDate, endDate]);
  }

  /**
   * 获取最新的各类型记录
   */
  static async getLatestByTypes(userId, types = []) {
    if (types.length === 0) {
      return [];
    }

    const placeholders = types.map(() => '?').join(', ');
    const sql = `
      SELECT hr.*
      FROM health_records hr
      INNER JOIN (
        SELECT type, MAX(record_date) as max_date
        FROM health_records
        WHERE user_id = ? AND type IN (${placeholders})
        GROUP BY type
      ) latest ON hr.type = latest.type AND hr.record_date = latest.max_date
      WHERE hr.user_id = ?
    `;

    return query(sql, [userId, ...types, userId]);
  }

  /**
   * 更新健康记录
   */
  static async update(id, userId, updateData) {
    const { value, note, recordDate } = updateData;
    const updates = [];
    const values = [];

    if (value !== undefined) {
      updates.push('value = ?');
      values.push(value);
    }
    if (note !== undefined) {
      updates.push('note = ?');
      values.push(note);
    }
    if (recordDate !== undefined) {
      updates.push('record_date = ?');
      values.push(recordDate);
    }

    if (updates.length === 0) return false;

    values.push(id, userId);
    const sql = `UPDATE health_records SET ${updates.join(', ')} WHERE id = ? AND user_id = ?`;
    const result = await query(sql, values);
    return result.affectedRows > 0;
  }

  /**
   * 删除健康记录
   */
  static async delete(id, userId) {
    const sql = 'DELETE FROM health_records WHERE id = ? AND user_id = ?';
    const result = await query(sql, [id, userId]);
    return result.affectedRows > 0;
  }

  /**
   * 获取用户记录总数
   */
  static async countByUserId(userId) {
    const sql = 'SELECT COUNT(*) as count FROM health_records WHERE user_id = ?';
    const rows = await query(sql, [userId]);
    return rows[0].count;
  }
}

module.exports = HealthRecordModel;
