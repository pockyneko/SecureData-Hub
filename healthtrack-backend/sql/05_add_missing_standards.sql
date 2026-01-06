-- =============================================
-- 添加缺失的健康标准数据
-- 包括：青少年、儿童、以及其他缺失的组合
-- =============================================

USE healthtrack;

-- =============================================
-- 青少年（teen）健康标准
-- =============================================

-- 青少年 - 久坐
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'teen', 'all', 'sedentary',
  5000, 8000, 12000,
  60, 85, 205,
  8, 9, 10,
  120, 80,
  16.0, 18.5, 24, 28,
  2000,
  '久坐青少年：建议增加户外活动和体育运动，减少屏幕时间'
);

-- 青少年 - 轻度活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'teen', 'all', 'lightly_active',
  7000, 10000, 15000,
  55, 80, 205,
  8, 9, 10,
  120, 80,
  16.0, 18.5, 24, 28,
  2200,
  '轻度活动青少年：继续保持活动习惯，可逐步增加运动强度'
);

-- 青少年 - 中等活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'teen', 'all', 'moderately_active',
  10000, 12000, 18000,
  50, 75, 205,
  8, 9, 10,
  120, 80,
  16.0, 18.5, 24, 28,
  2500,
  '中等活动青少年：保持良好的运动习惯，注意营养均衡'
);

-- 青少年 - 高度活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'teen', 'all', 'very_active',
  12000, 15000, 22000,
  45, 70, 205,
  8, 9, 10,
  120, 80,
  16.0, 18.5, 24, 28,
  3000,
  '高度活动青少年：确保充足睡眠和营养，避免运动过度'
);

-- 青少年 - 极高活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'teen', 'all', 'extremely_active',
  15000, 20000, 25000,
  40, 65, 205,
  8, 10, 11,
  120, 80,
  16.0, 18.5, 24, 28,
  3500,
  '极高活动青少年：密切关注身体恢复，保证充足休息'
);

-- =============================================
-- 儿童（child）健康标准
-- =============================================

-- 儿童 - 久坐
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'child', 'all', 'sedentary',
  6000, 10000, 15000,
  70, 100, 210,
  9, 10, 12,
  110, 70,
  14.0, 15.0, 19, 23,
  1500,
  '久坐儿童：建议增加户外游戏和体育活动，限制电子屏幕时间'
);

-- 儿童 - 轻度活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'child', 'all', 'lightly_active',
  8000, 12000, 18000,
  65, 95, 210,
  9, 10, 12,
  110, 70,
  14.0, 15.0, 19, 23,
  1700,
  '轻度活动儿童：保持活泼好动，培养运动兴趣'
);

-- 儿童 - 中等活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'child', 'all', 'moderately_active',
  10000, 14000, 20000,
  60, 90, 210,
  9, 10, 12,
  110, 70,
  14.0, 15.0, 19, 23,
  1800,
  '中等活动儿童：非常棒的活动量，继续保持！'
);

-- 儿童 - 高度活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'child', 'all', 'very_active',
  12000, 16000, 22000,
  55, 85, 210,
  9, 10, 12,
  110, 70,
  14.0, 15.0, 19, 23,
  2000,
  '高度活动儿童：注意安全和充足休息'
);

-- 儿童 - 极高活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'child', 'all', 'extremely_active',
  15000, 18000, 25000,
  50, 80, 210,
  10, 11, 12,
  110, 70,
  14.0, 15.0, 19, 23,
  2200,
  '极高活动儿童：确保充足睡眠和营养摄入'
);

-- =============================================
-- 老年（senior）- 补充缺失的活动等级
-- =============================================

-- 老年 - 久坐
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'senior', 'all', 'sedentary',
  2000, 4000, 6000,
  60, 90, 150,
  7, 8, 9,
  130, 85,
  18.5, 18.5, 27, 32,
  1800,
  '久坐老年人：建议从轻度散步开始，循序渐进增加活动量'
);

-- 老年 - 轻度活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'senior', 'all', 'lightly_active',
  3000, 5000, 8000,
  60, 85, 150,
  7, 8, 9,
  130, 85,
  18.5, 18.5, 27, 32,
  2000,
  '轻度活动老年人：保持适度活动，注意关节保护'
);

-- =============================================
-- 中年（middle_age）- 补充缺失的活动等级
-- =============================================

-- 中年 - 久坐
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'middle_age', 'all', 'sedentary',
  4000, 6000, 8000,
  60, 85, 170,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2200,
  '久坐中年人：建议增加运动，注意控制体重和血压'
);

-- 中年 - 轻度活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'middle_age', 'all', 'lightly_active',
  5000, 7000, 10000,
  55, 80, 170,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2400,
  '轻度活动中年人：保持规律运动，定期体检'
);

-- =============================================
-- 成人（adult）- 补充缺失的活动等级
-- =============================================

-- 成人 - 轻度活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'all', 'lightly_active',
  5000, 8000, 12000,
  58, 78, 185,
  7, 8, 9,
  120, 80,
  18.5, 18.5, 24, 29.9,
  2300,
  '轻度活动成人：可以逐步增加运动强度，保持健康生活方式'
);

-- 成人 - 极高活动
INSERT IGNORE INTO health_standards_reference (
  id, age_group, gender, activity_level, daily_steps_min, daily_steps_optimal, daily_steps_max,
  resting_heart_rate_min, resting_heart_rate_normal, max_heart_rate,
  sleep_min, sleep_optimal, sleep_max,
  blood_pressure_systolic_normal, blood_pressure_diastolic_normal,
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  water_intake_daily_ml, notes
) VALUES (
  UUID(), 'adult', 'all', 'extremely_active',
  15000, 20000, 25000,
  45, 65, 185,
  7, 9, 10,
  120, 80,
  18.5, 18.5, 24, 29.9,
  3500,
  '极高活动成人：注意运动后恢复和营养补充，避免过度训练'
);

-- =============================================
-- 完成提示
-- =============================================
SELECT CONCAT('✅ 已添加健康标准数据，当前共 ', COUNT(*), ' 条记录') AS message 
FROM health_standards_reference;
