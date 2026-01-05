-- 创建 health_standards_reference 表
CREATE TABLE IF NOT EXISTS healthtrack.health_standards_reference (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  age_group ENUM('child', 'teen', 'adult', 'middle_age', 'senior') NOT NULL,
  gender ENUM('male', 'female', 'all') NOT NULL,
  activity_level ENUM('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active') NOT NULL,
  daily_steps_min INT,
  daily_steps_optimal INT,
  daily_steps_max INT,
  resting_heart_rate_min INT,
  resting_heart_rate_normal INT,
  max_heart_rate INT,
  sleep_min DECIMAL(4,2),
  sleep_optimal DECIMAL(4,2),
  sleep_max DECIMAL(4,2),
  blood_pressure_systolic_normal INT,
  blood_pressure_diastolic_normal INT,
  bmi_min DECIMAL(5,2),
  bmi_optimal_min DECIMAL(5,2),
  bmi_optimal_max DECIMAL(5,2),
  bmi_max DECIMAL(5,2),
  water_intake_daily_ml INT,
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_standard (age_group, gender, activity_level),
  KEY idx_age_group (age_group)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入标准数据
INSERT IGNORE INTO healthtrack.health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'all', 'moderately_active',
  7000, 10000, 15000,
  55, 75, 185,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2500,
  '中等活动量成人：保持稳定的运动习惯和健康作息'
);

INSERT IGNORE INTO healthtrack.health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'all', 'sedentary',
  3000, 6000, 8000,
  60, 80, 185,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2000,
  '低活动量成人：逐步增加日常活动，避免久坐'
);

INSERT IGNORE INTO healthtrack.health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'all', 'very_active',
  12000, 15000, 20000,
  50, 70, 185,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  3000,
  '高活动量成人：注意恢复和营养补充，避免过度训练'
);

INSERT IGNORE INTO healthtrack.health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'middle_age', 'all', 'moderately_active',
  6000, 8000, 12000,
  60, 80, 170,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2500,
  '中年人群：重点关注血压、血糖，循序渐进增加运动'
);

INSERT IGNORE INTO healthtrack.health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'senior', 'all', 'moderately_active',
  5000, 7000, 10000,
  60, 85, 155,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2000,
  '老年人群：以柔和运动为主，如散步、太极，需定期体检'
);

-- 创建视图
DROP VIEW IF EXISTS healthtrack.v_user_personalized_standards;
CREATE VIEW healthtrack.v_user_personalized_standards AS
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
FROM healthtrack.users u
LEFT JOIN healthtrack.user_health_profiles hp ON u.id = hp.user_id
LEFT JOIN healthtrack.health_standards_reference hsr ON 
  hp.age_group = hsr.age_group AND 
  (hsr.gender = u.gender OR hsr.gender = 'all') AND
  hp.activity_level = hsr.activity_level
WHERE u.deleted_at IS NULL;
