/**
 * 运动建议模型
 */

const { query } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class ExerciseAdviceModel {
  /**
   * 获取运动建议列表
   */
  static async findAll(options = {}) {
    const { weather, timeSlot, intensity, limit = 20, offset = 0 } = options;
    let sql = 'SELECT * FROM exercise_advice WHERE is_active = 1';
    const params = [];

    if (weather) {
      sql += ' AND (weather = ? OR weather = "all")';
      params.push(weather);
    }

    if (timeSlot) {
      sql += ' AND (time_slot = ? OR time_slot = "all")';
      params.push(timeSlot);
    }

    if (intensity) {
      sql += ' AND intensity = ?';
      params.push(intensity);
    }

    sql += ' ORDER BY sort_order ASC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return query(sql, params);
  }

  /**
   * 根据条件获取推荐运动
   */
  static async getRecommendations(conditions = {}) {
    const { weather = 'sunny', timeSlot = 'morning', limit = 5 } = conditions;
    
    const sql = `
      SELECT * FROM exercise_advice 
      WHERE is_active = 1 
        AND (weather = ? OR weather = 'all')
        AND (time_slot = ? OR time_slot = 'all')
      ORDER BY sort_order ASC
      LIMIT ?
    `;

    return query(sql, [weather, timeSlot, limit]);
  }

  /**
   * 获取所有可用的天气类型
   */
  static async getWeatherTypes() {
    const sql = 'SELECT DISTINCT weather FROM exercise_advice WHERE is_active = 1';
    return query(sql);
  }

  /**
   * 创建运动建议（管理员）
   */
  static async create(adviceData) {
    const id = uuidv4();
    const sql = `
      INSERT INTO exercise_advice (id, name, description, weather, time_slot, intensity, duration, calories_burned, image_url, sort_order, is_active, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW())
    `;
    await query(sql, [
      id,
      adviceData.name,
      adviceData.description,
      adviceData.weather || 'all',
      adviceData.timeSlot || 'all',
      adviceData.intensity || 'medium',
      adviceData.duration || 30,
      adviceData.caloriesBurned || 0,
      adviceData.imageUrl || null,
      adviceData.sortOrder || 0
    ]);
    return { id, ...adviceData };
  }
}

module.exports = ExerciseAdviceModel;
