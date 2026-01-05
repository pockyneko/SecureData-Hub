-- 创建用户健康档案表
CREATE TABLE IF NOT EXISTS healthtrack.user_health_profiles (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  age_group ENUM('child', 'teen', 'adult', 'middle_age', 'senior') DEFAULT NULL,
  activity_level ENUM('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active') DEFAULT 'moderately_active',
  health_condition ENUM('excellent', 'good', 'fair', 'poor') DEFAULT 'good',
  has_cardiovascular_issues TINYINT(1) DEFAULT 0,
  has_diabetes TINYINT(1) DEFAULT 0,
  has_joint_issues TINYINT(1) DEFAULT 0,
  is_pregnant TINYINT(1) DEFAULT 0,
  is_recovering TINYINT(1) DEFAULT 0,
  personalized_steps_goal INT DEFAULT NULL,
  personalized_heart_rate_min INT DEFAULT NULL,
  personalized_heart_rate_max INT DEFAULT NULL,
  personalized_sleep_goal DECIMAL(4,2) DEFAULT NULL,
  personalized_water_goal INT DEFAULT NULL,
  doctor_notes TEXT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_id (user_id),
  CONSTRAINT fk_user_health_profiles_user FOREIGN KEY (user_id) REFERENCES healthtrack.users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
