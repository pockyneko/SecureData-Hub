-- =============================================
-- HealthTrack 演示用户和数据脚本
-- 用于测试和演示目的
-- =============================================

USE healthtrack;

-- =============================================
-- 创建演示用户
-- 密码: demo123456 (bcrypt加密后)
-- =============================================

INSERT INTO users (id, username, email, password, nickname, height, gender, birthday, created_at) VALUES
('demo-user-001', 'demo', 'demo@healthtrack.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.e6Wx8JIyP/XK4W', '演示用户', 175.00, 'male', '1995-06-15', NOW()),
('demo-user-002', 'test', 'test@healthtrack.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.e6Wx8JIyP/XK4W', '测试用户', 165.00, 'female', '1998-03-20', NOW());

-- =============================================
-- 为演示用户创建目标
-- =============================================

INSERT INTO user_goals (id, user_id, steps_goal, water_goal, sleep_goal, calories_goal, weight_goal) VALUES
('goal-001', 'demo-user-001', 10000, 2500, 8.00, 2200, 70.00),
('goal-002', 'demo-user-002', 8000, 2000, 7.50, 1800, 55.00);

-- =============================================
-- 为演示用户生成30天历史数据
-- =============================================

-- 使用存储过程生成模拟数据
DELIMITER //

DROP PROCEDURE IF EXISTS generate_demo_data //

CREATE PROCEDURE generate_demo_data(IN p_user_id VARCHAR(36), IN p_base_weight DECIMAL(5,2))
BEGIN
    DECLARE i INT DEFAULT 30;
    DECLARE record_date DATE;
    DECLARE weight_val DECIMAL(5,2);
    DECLARE steps_val INT;
    DECLARE heart_rate_val INT;
    DECLARE bp_sys_val INT;
    DECLARE bp_dia_val INT;
    DECLARE sleep_val DECIMAL(4,2);
    DECLARE water_val INT;
    DECLARE calories_val INT;
    
    WHILE i > 0 DO
        SET record_date = DATE_SUB(CURDATE(), INTERVAL i DAY);
        
        -- 生成体重数据（模拟轻微下降趋势）
        SET weight_val = p_base_weight - (30 - i) * 0.05 + (RAND() - 0.5) * 0.4;
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'weight', weight_val, record_date);
        
        -- 生成步数数据
        SET steps_val = 5000 + FLOOR(RAND() * 7000);
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'steps', steps_val, record_date);
        
        -- 生成心率数据
        SET heart_rate_val = 65 + FLOOR(RAND() * 20);
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'heart_rate', heart_rate_val, record_date);
        
        -- 生成血压数据
        SET bp_sys_val = 110 + FLOOR(RAND() * 20);
        SET bp_dia_val = 70 + FLOOR(RAND() * 15);
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'blood_pressure_sys', bp_sys_val, record_date);
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'blood_pressure_dia', bp_dia_val, record_date);
        
        -- 生成睡眠数据
        SET sleep_val = 6 + RAND() * 3;
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'sleep', ROUND(sleep_val, 1), record_date);
        
        -- 生成饮水数据
        SET water_val = 1200 + FLOOR(RAND() * 1300);
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'water', water_val, record_date);
        
        -- 生成卡路里数据
        SET calories_val = 1500 + FLOOR(RAND() * 1000);
        INSERT INTO health_records (id, user_id, type, value, record_date) 
        VALUES (UUID(), p_user_id, 'calories', calories_val, record_date);
        
        SET i = i - 1;
    END WHILE;
END //

DELIMITER ;

-- 调用存储过程生成数据
CALL generate_demo_data('demo-user-001', 72.00);
CALL generate_demo_data('demo-user-002', 58.00);

-- 删除存储过程
DROP PROCEDURE IF EXISTS generate_demo_data;

-- =============================================
-- 完成提示
-- =============================================
SELECT '✅ 演示数据生成完成!' AS message;
SELECT '演示账号: demo / demo123456' AS demo_account;
SELECT '测试账号: test / demo123456' AS test_account;
SELECT CONCAT('健康记录总数: ', COUNT(*), ' 条') AS total_records FROM health_records;
