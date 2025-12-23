-- =============================================
-- HealthTrack 数据库初始化脚本
-- 数据库: MySQL 8.0+
-- 字符集: utf8mb4
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS healthtrack 
  DEFAULT CHARACTER SET utf8mb4 
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE healthtrack;

-- =============================================
-- 表结构定义
-- =============================================

-- ---------------------------------------------
-- 1. 用户表 (users)
-- ---------------------------------------------
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT '用户ID (UUID)',
  username VARCHAR(50) NOT NULL COMMENT '用户名',
  email VARCHAR(100) NOT NULL COMMENT '邮箱',
  password VARCHAR(255) NOT NULL COMMENT '密码 (bcrypt加密)',
  nickname VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  avatar VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
  height DECIMAL(5,2) DEFAULT NULL COMMENT '身高 (cm)',
  gender ENUM('male', 'female', 'other') DEFAULT NULL COMMENT '性别',
  birthday DATE DEFAULT NULL COMMENT '生日',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted_at DATETIME DEFAULT NULL COMMENT '删除时间 (软删除)',
  
  UNIQUE KEY uk_username (username),
  UNIQUE KEY uk_email (email),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ---------------------------------------------
-- 2. 健康记录表 (health_records)
-- ---------------------------------------------
DROP TABLE IF EXISTS health_records;
CREATE TABLE health_records (
  id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT '记录ID (UUID)',
  user_id VARCHAR(36) NOT NULL COMMENT '用户ID',
  type ENUM('weight', 'steps', 'blood_pressure_sys', 'blood_pressure_dia', 'heart_rate', 'sleep', 'water', 'calories') NOT NULL COMMENT '数据类型',
  value DECIMAL(10,2) NOT NULL COMMENT '数值',
  note VARCHAR(500) DEFAULT NULL COMMENT '备注',
  record_date DATE NOT NULL COMMENT '记录日期',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  INDEX idx_user_id (user_id),
  INDEX idx_user_type (user_id, type),
  INDEX idx_user_date (user_id, record_date),
  INDEX idx_record_date (record_date),
  
  CONSTRAINT fk_health_records_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康记录表';

-- ---------------------------------------------
-- 3. 用户目标表 (user_goals)
-- ---------------------------------------------
DROP TABLE IF EXISTS user_goals;
CREATE TABLE user_goals (
  id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT '目标ID (UUID)',
  user_id VARCHAR(36) NOT NULL COMMENT '用户ID',
  steps_goal INT DEFAULT 8000 COMMENT '每日步数目标',
  water_goal INT DEFAULT 2000 COMMENT '每日饮水目标 (ml)',
  sleep_goal DECIMAL(4,2) DEFAULT 8.00 COMMENT '每日睡眠目标 (小时)',
  calories_goal INT DEFAULT 2000 COMMENT '每日卡路里目标 (kcal)',
  weight_goal DECIMAL(5,2) DEFAULT NULL COMMENT '体重目标 (kg)',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  UNIQUE KEY uk_user_id (user_id),
  
  CONSTRAINT fk_user_goals_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户目标表';

-- ---------------------------------------------
-- 4. 健康百科表 (health_tips)
-- ---------------------------------------------
DROP TABLE IF EXISTS health_tips;
CREATE TABLE health_tips (
  id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT '百科ID (UUID)',
  title VARCHAR(200) NOT NULL COMMENT '标题',
  content TEXT NOT NULL COMMENT '内容',
  category VARCHAR(50) NOT NULL COMMENT '分类',
  image_url VARCHAR(255) DEFAULT NULL COMMENT '配图URL',
  sort_order INT DEFAULT 0 COMMENT '排序权重',
  is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  INDEX idx_category (category),
  INDEX idx_is_active (is_active),
  INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康百科表';

-- ---------------------------------------------
-- 5. 运动建议表 (exercise_advice)
-- ---------------------------------------------
DROP TABLE IF EXISTS exercise_advice;
CREATE TABLE exercise_advice (
  id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT '建议ID (UUID)',
  name VARCHAR(100) NOT NULL COMMENT '运动名称',
  description TEXT NOT NULL COMMENT '运动描述',
  weather ENUM('all', 'sunny', 'cloudy', 'rainy', 'snowy', 'hot', 'cold') DEFAULT 'all' COMMENT '适宜天气',
  time_slot ENUM('all', 'morning', 'afternoon', 'evening', 'night') DEFAULT 'all' COMMENT '适宜时段',
  intensity ENUM('low', 'medium', 'high') DEFAULT 'medium' COMMENT '运动强度',
  duration INT DEFAULT 30 COMMENT '建议时长 (分钟)',
  calories_burned INT DEFAULT 0 COMMENT '消耗卡路里估算',
  image_url VARCHAR(255) DEFAULT NULL COMMENT '配图URL',
  sort_order INT DEFAULT 0 COMMENT '排序权重',
  is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  INDEX idx_weather (weather),
  INDEX idx_time_slot (time_slot),
  INDEX idx_intensity (intensity),
  INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='运动建议表';

-- =============================================
-- 视图定义
-- =============================================

-- 用户健康概览视图
CREATE OR REPLACE VIEW v_user_health_overview AS
SELECT 
  u.id AS user_id,
  u.username,
  u.nickname,
  u.height,
  (SELECT value FROM health_records WHERE user_id = u.id AND type = 'weight' ORDER BY record_date DESC LIMIT 1) AS latest_weight,
  (SELECT value FROM health_records WHERE user_id = u.id AND type = 'steps' ORDER BY record_date DESC LIMIT 1) AS latest_steps,
  (SELECT value FROM health_records WHERE user_id = u.id AND type = 'heart_rate' ORDER BY record_date DESC LIMIT 1) AS latest_heart_rate,
  (SELECT COUNT(*) FROM health_records WHERE user_id = u.id) AS total_records,
  g.steps_goal,
  g.weight_goal
FROM users u
LEFT JOIN user_goals g ON u.id = g.user_id
WHERE u.deleted_at IS NULL;

-- =============================================
-- 完成提示
-- =============================================
SELECT '✅ HealthTrack 数据库表结构创建完成!' AS message;
