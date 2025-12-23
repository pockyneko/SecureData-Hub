/**
 * 用户目标模型
 * 处理健康目标设定相关的数据库操作
 */

const { query } = require('../config/database');
const { v4: uuidv4 } = require('uuid');
const config = require('../config');

class UserGoalModel {
  /**
   * 创建或更新用户目标
   */
  static async upsert(userId, goals) {
    const existingGoals = await this.findByUserId(userId);

    if (existingGoals) {
      // 更新
      const sql = `
        UPDATE user_goals SET 
          steps_goal = ?,
          water_goal = ?,
          sleep_goal = ?,
          calories_goal = ?,
          weight_goal = ?,
          updated_at = NOW()
        WHERE user_id = ?
      `;
      await query(sql, [
        goals.stepsGoal ?? existingGoals.steps_goal,
        goals.waterGoal ?? existingGoals.water_goal,
        goals.sleepGoal ?? existingGoals.sleep_goal,
        goals.caloriesGoal ?? existingGoals.calories_goal,
        goals.weightGoal ?? existingGoals.weight_goal,
        userId
      ]);
    } else {
      // 创建
      const id = uuidv4();
      const sql = `
        INSERT INTO user_goals (id, user_id, steps_goal, water_goal, sleep_goal, calories_goal, weight_goal, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
      `;
      await query(sql, [
        id,
        userId,
        goals.stepsGoal || config.defaultGoals.steps,
        goals.waterGoal || config.defaultGoals.water,
        goals.sleepGoal || config.defaultGoals.sleep,
        goals.caloriesGoal || config.defaultGoals.calories,
        goals.weightGoal || null
      ]);
    }

    return this.findByUserId(userId);
  }

  /**
   * 获取用户目标
   */
  static async findByUserId(userId) {
    const sql = 'SELECT * FROM user_goals WHERE user_id = ?';
    const rows = await query(sql, [userId]);
    return rows[0] || null;
  }

  /**
   * 获取用户目标（含默认值）
   */
  static async findByUserIdWithDefaults(userId) {
    const goals = await this.findByUserId(userId);
    
    if (goals) {
      return {
        stepsGoal: goals.steps_goal,
        waterGoal: goals.water_goal,
        sleepGoal: goals.sleep_goal,
        caloriesGoal: goals.calories_goal,
        weightGoal: goals.weight_goal
      };
    }

    // 返回默认目标
    return {
      stepsGoal: config.defaultGoals.steps,
      waterGoal: config.defaultGoals.water,
      sleepGoal: config.defaultGoals.sleep,
      caloriesGoal: config.defaultGoals.calories,
      weightGoal: null
    };
  }
}

module.exports = UserGoalModel;
