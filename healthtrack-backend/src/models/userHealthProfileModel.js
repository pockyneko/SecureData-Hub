/**
 * 用户健康档案模型
 * 处理个性化健康标准和用户健康档案的数据库操作
 */

const { query } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class UserHealthProfileModel {
  /**
   * 创建用户健康档案
   */
  static async create(userId, profileData) {
    const {
      ageGroup,
      activityLevel = 'moderately_active',
      healthCondition = 'good',
      hasCardiovascularIssues = 0,
      hasDiabetes = 0,
      hasJointIssues = 0,
      isPregnant = 0,
      isRecovering = 0,
      personalizedStepsGoal,
      personalizedHeartRateMin,
      personalizedHeartRateMax,
      personalizedSleepGoal,
      personalizedWaterGoal,
      doctorNotes
    } = profileData;

    const id = uuidv4();

    const sql = `
      INSERT INTO user_health_profiles (
        id, user_id, age_group, activity_level, health_condition,
        has_cardiovascular_issues, has_diabetes, has_joint_issues,
        is_pregnant, is_recovering,
        personalized_steps_goal, personalized_heart_rate_min, personalized_heart_rate_max,
        personalized_sleep_goal, personalized_water_goal, doctor_notes,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
    `;

    await query(sql, [
      id,
      userId,
      ageGroup,
      activityLevel,
      healthCondition,
      hasCardiovascularIssues,
      hasDiabetes,
      hasJointIssues,
      isPregnant,
      isRecovering,
      personalizedStepsGoal || null,
      personalizedHeartRateMin || null,
      personalizedHeartRateMax || null,
      personalizedSleepGoal || null,
      personalizedWaterGoal || null,
      doctorNotes || null
    ]);

    return this.findByUserId(userId);
  }

  /**
   * 获取用户健康档案
   */
  static async findByUserId(userId) {
    const sql = 'SELECT * FROM user_health_profiles WHERE user_id = ?';
    const rows = await query(sql, [userId]);
    return rows[0] || null;
  }

  /**
   * 更新用户健康档案
   */
  static async update(userId, profileData) {
    const {
      ageGroup,
      activityLevel,
      healthCondition,
      hasCardiovascularIssues,
      hasDiabetes,
      hasJointIssues,
      isPregnant,
      isRecovering,
      personalizedStepsGoal,
      personalizedHeartRateMin,
      personalizedHeartRateMax,
      personalizedSleepGoal,
      personalizedWaterGoal,
      doctorNotes
    } = profileData;

    const updates = [];
    const values = [];

    if (ageGroup !== undefined) {
      updates.push('age_group = ?');
      values.push(ageGroup);
    }
    if (activityLevel !== undefined) {
      updates.push('activity_level = ?');
      values.push(activityLevel);
    }
    if (healthCondition !== undefined) {
      updates.push('health_condition = ?');
      values.push(healthCondition);
    }
    if (hasCardiovascularIssues !== undefined) {
      updates.push('has_cardiovascular_issues = ?');
      values.push(hasCardiovascularIssues);
    }
    if (hasDiabetes !== undefined) {
      updates.push('has_diabetes = ?');
      values.push(hasDiabetes);
    }
    if (hasJointIssues !== undefined) {
      updates.push('has_joint_issues = ?');
      values.push(hasJointIssues);
    }
    if (isPregnant !== undefined) {
      updates.push('is_pregnant = ?');
      values.push(isPregnant);
    }
    if (isRecovering !== undefined) {
      updates.push('is_recovering = ?');
      values.push(isRecovering);
    }
    if (personalizedStepsGoal !== undefined) {
      updates.push('personalized_steps_goal = ?');
      values.push(personalizedStepsGoal);
    }
    if (personalizedHeartRateMin !== undefined) {
      updates.push('personalized_heart_rate_min = ?');
      values.push(personalizedHeartRateMin);
    }
    if (personalizedHeartRateMax !== undefined) {
      updates.push('personalized_heart_rate_max = ?');
      values.push(personalizedHeartRateMax);
    }
    if (personalizedSleepGoal !== undefined) {
      updates.push('personalized_sleep_goal = ?');
      values.push(personalizedSleepGoal);
    }
    if (personalizedWaterGoal !== undefined) {
      updates.push('personalized_water_goal = ?');
      values.push(personalizedWaterGoal);
    }
    if (doctorNotes !== undefined) {
      updates.push('doctor_notes = ?');
      values.push(doctorNotes);
    }

    if (updates.length === 0) {
      return this.findByUserId(userId);
    }

    updates.push('updated_at = NOW()');
    values.push(userId);

    const sql = `UPDATE user_health_profiles SET ${updates.join(', ')} WHERE user_id = ?`;
    await query(sql, values);

    return this.findByUserId(userId);
  }

  /**
   * 删除用户健康档案
   */
  static async deleteByUserId(userId) {
    const sql = 'DELETE FROM user_health_profiles WHERE user_id = ?';
    await query(sql, [userId]);
  }

  /**
   * 获取用户的个性化健康标准
   * 从 v_user_personalized_standards 视图查询
   */
  static async getPersonalizedStandards(userId) {
    const sql = `
      SELECT * FROM v_user_personalized_standards
      WHERE user_id = ?
    `;
    const rows = await query(sql, [userId]);
    return rows[0] || null;
  }

  /**
   * 计算用户年龄组
   */
  static calculateAgeGroup(birthday) {
    if (!birthday) return null;

    const birthDate = new Date(birthday);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();

    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    if (age <= 12) return 'child';
    if (age <= 18) return 'teen';
    if (age <= 40) return 'adult';
    if (age <= 65) return 'middle_age';
    return 'senior';
  }

  /**
   * 根据用户信息自动初始化个性化档案
   */
  static async initializeForNewUser(userId, userData) {
    const ageGroup = this.calculateAgeGroup(userData.birthday);

    // 查看档案是否已存在
    const existing = await this.findByUserId(userId);
    if (existing) {
      return existing;
    }

    return this.create(userId, {
      ageGroup,
      activityLevel: 'moderately_active',
      healthCondition: 'good'
    });
  }
}

module.exports = UserHealthProfileModel;
