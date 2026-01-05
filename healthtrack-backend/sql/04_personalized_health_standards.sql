-- =============================================
-- 个性化健康标准扩展脚本
-- 添加用户健康档案表，实现基于个人特征的个性化健康标准
-- =============================================

USE healthtrack;

-- =============================================
-- 创建用户健康档案表
-- =============================================
DROP TABLE IF EXISTS user_health_profiles;
CREATE TABLE user_health_profiles (
  id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT '档案ID (UUID)',
  user_id VARCHAR(36) NOT NULL UNIQUE COMMENT '用户ID',
  
  -- 基础信息
  age_group ENUM('child', 'teen', 'adult', 'middle_age', 'senior') COMMENT '年龄段: 儿童(0-12), 青少年(13-18), 成人(19-40), 中年(41-65), 老年(65+)',
  
  -- 健康状态
  activity_level ENUM('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active') DEFAULT 'moderately_active' COMMENT '运动水平',
  health_condition ENUM('excellent', 'good', 'fair', 'poor') DEFAULT 'good' COMMENT '健康状态评估',
  
  -- 特殊情况标记
  has_cardiovascular_issues TINYINT(1) DEFAULT 0 COMMENT '有心血管问题',
  has_diabetes TINYINT(1) DEFAULT 0 COMMENT '有糖尿病',
  has_joint_issues TINYINT(1) DEFAULT 0 COMMENT '有关节问题',
  is_pregnant TINYINT(1) DEFAULT 0 COMMENT '孕期',
  is_recovering TINYINT(1) DEFAULT 0 COMMENT '康复期',
  
  -- 个性化标准（可被用户覆盖）
  personalized_steps_goal INT COMMENT '个性化每日步数目标',
  personalized_heart_rate_min INT COMMENT '个性化目标心率最小值',
  personalized_heart_rate_max INT COMMENT '个性化目标心率最大值',
  personalized_sleep_goal DECIMAL(4,2) COMMENT '个性化睡眠目标（小时）',
  personalized_water_goal INT COMMENT '个性化饮水目标（ml）',
  
  -- 医生建议
  doctor_notes TEXT COMMENT '医生特殊建议',
  
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  INDEX idx_user_id (user_id),
  INDEX idx_age_group (age_group),
  INDEX idx_activity_level (activity_level),
  
  CONSTRAINT fk_user_health_profiles FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户个性化健康档案表';

-- =============================================
-- 创建健康标准参考表
-- 用于存储不同人群的健康标准范围
-- =============================================
DROP TABLE IF EXISTS health_standards_reference;
CREATE TABLE health_standards_reference (
  id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT '标准ID (UUID)',
  
  -- 人群标签
  age_group ENUM('child', 'teen', 'adult', 'middle_age', 'senior') NOT NULL COMMENT '年龄段',
  gender ENUM('male', 'female', 'all') NOT NULL COMMENT '性别',
  activity_level ENUM('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active') NOT NULL COMMENT '运动水平',
  
  -- 步数标准
  daily_steps_min INT COMMENT '每日步数最低建议',
  daily_steps_optimal INT COMMENT '每日步数最优值',
  daily_steps_max INT COMMENT '每日步数最大值',
  
  -- 心率标准
  resting_heart_rate_min INT COMMENT '静息心率最小值（bpm）',
  resting_heart_rate_normal INT COMMENT '静息心率正常范围最大值（bpm）',
  max_heart_rate INT COMMENT '最大心率估算（bpm）',
  
  -- 睡眠标准
  sleep_min DECIMAL(4,2) COMMENT '每日睡眠最少小时数',
  sleep_optimal DECIMAL(4,2) COMMENT '每日睡眠最优小时数',
  sleep_max DECIMAL(4,2) COMMENT '每日睡眠最多小时数',
  
  -- 血压标准
  blood_pressure_systolic_normal INT COMMENT '收缩压正常上限（mmHg）',
  blood_pressure_diastolic_normal INT COMMENT '舒张压正常上限（mmHg）',
  
  -- 体重/BMI标准
  bmi_min DECIMAL(5,2) COMMENT 'BMI最小值',
  bmi_optimal_min DECIMAL(5,2) COMMENT 'BMI最优范围最小值',
  bmi_optimal_max DECIMAL(5,2) COMMENT 'BMI最优范围最大值',
  bmi_max DECIMAL(5,2) COMMENT 'BMI最大值',
  
  -- 饮水标准
  water_intake_daily_ml INT COMMENT '每日饮水建议（ml）',
  
  -- 描述和建议
  notes TEXT COMMENT '说明和建议',
  
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  UNIQUE KEY uk_standard (age_group, gender, activity_level),
  INDEX idx_age_group (age_group),
  INDEX idx_gender (gender)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康标准参考表';

-- =============================================
-- 插入健康标准参考数据
-- =============================================

-- 成人女性 - 久坐
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'female', 'sedentary',
  3000, 5000, 7000,
  60, 80, 220 - 30,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2000,
  '久坐成年女性：建议逐步增加活动量，从轻运动开始'
);

-- 成人男性 - 久坐
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'male', 'sedentary',
  4000, 6000, 8000,
  60, 80, 220 - 30,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2500,
  '久坐成年男性：建议循序渐进增加步数和有氧运动'
);

-- 成人 - 中等活动量
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'all', 'moderately_active',
  7000, 10000, 15000,
  55, 75, 220 - 35,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2500,
  '中等活动量成人：保持稳定的运动习惯和健康作息'
);

-- 成人 - 活跃
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'all', 'very_active',
  12000, 15000, 20000,
  50, 70, 220 - 35,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  3000,
  '高活动量成人：注意恢复和营养补充，避免过度训练'
);

-- 中年 - 中等活动量
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'middle_age', 'all', 'moderately_active',
  6000, 8000, 12000,
  60, 80, 220 - 50,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2500,
  '中年人群：重点关注血压、血糖，循序渐进增加运动'
);

-- 老年 - 中等活动量
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'senior', 'all', 'moderately_active',
  4000, 7000, 10000,
  60, 85, 220 - 70,
  7, 8, 9,
  130, 85,
  18.5, 18.5, 27, 32,
  2200,
  '老年人群：强化平衡和肌肉训练，防止跌倒，定期体检'
);

-- 孕期女性
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'female', 'lightly_active',
  4000, 6000, 8000,
  60, 90, 180,
  8, 9, 10,
  120, 80,
  18.5, 18.5, 30, 35,
  3000,
  '孕期女性：避免高强度运动，优先轻度散步，增加水分摄入，定期产检'
);

-- =============================================
-- 修改 user_goals 表，添加历史记录字段
-- =============================================
ALTER TABLE user_goals ADD COLUMN reason_for_change VARCHAR(255) DEFAULT NULL COMMENT '目标调整原因';
ALTER TABLE user_goals ADD COLUMN is_personalized TINYINT(1) DEFAULT 0 COMMENT '是否为个性化自动调整的目标';

-- =============================================
-- 视图：用户个性化健康标准
-- =============================================
DROP VIEW IF EXISTS v_user_personalized_standards;
CREATE OR REPLACE VIEW v_user_personalized_standards AS
SELECT 
  u.id AS user_id,
  u.username,
  u.gender,
  YEAR(CURDATE()) - YEAR(u.birthday) AS age,
  hp.age_group,
  hp.activity_level,
  hp.health_condition,
  COALESCE(hp.personalized_steps_goal, hsr.daily_steps_optimal) AS recommended_daily_steps,
  COALESCE(hp.personalized_heart_rate_min, hsr.resting_heart_rate_min) AS recommended_heart_rate_min,
  COALESCE(hp.personalized_heart_rate_max, hsr.resting_heart_rate_normal) AS recommended_heart_rate_max,
  COALESCE(hp.personalized_sleep_goal, hsr.sleep_optimal) AS recommended_sleep_hours,
  COALESCE(hp.personalized_water_goal, hsr.water_intake_daily_ml) AS recommended_water_ml,
  hsr.bmi_optimal_min,
  hsr.bmi_optimal_max,
  hsr.blood_pressure_systolic_normal,
  hsr.blood_pressure_diastolic_normal,
  hp.doctor_notes,
  hp.updated_at
FROM users u
LEFT JOIN user_health_profiles hp ON u.id = hp.user_id
LEFT JOIN health_standards_reference hsr ON 
  hp.age_group = hsr.age_group AND 
  (hsr.gender = u.gender OR hsr.gender = 'all') AND
  hp.activity_level = hsr.activity_level
WHERE u.deleted_at IS NULL;

-- =============================================
-- 完成提示
-- =============================================
SELECT '✅ 个性化健康标准表结构创建完成！' AS message;
