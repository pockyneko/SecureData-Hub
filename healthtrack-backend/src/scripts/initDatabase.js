/**
 * 数据库初始化脚本
 * 在首次运行时创建必要的数据库表
 */

const mysql = require('mysql2/promise');
require('dotenv').config();

async function initDatabase() {
  console.log('========================================');
  console.log('🔧 HealthTrack 数据库初始化');
  console.log('========================================\n');

  // 数据库配置
  const config = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true
  };

  const dbName = process.env.DB_NAME || 'healthtrack';

  let connection;

  try {
    // 连接数据库（不指定数据库名）
    connection = await mysql.createConnection(config);
    console.log('✅ 数据库连接成功\n');

    // 创建数据库
    console.log(`📦 创建数据库 ${dbName}...`);
    await connection.query(`
      CREATE DATABASE IF NOT EXISTS ${dbName} 
      DEFAULT CHARACTER SET utf8mb4 
      DEFAULT COLLATE utf8mb4_unicode_ci
    `);
    console.log(`✅ 数据库 ${dbName} 创建成功\n`);

    // 切换到目标数据库
    await connection.query(`USE ${dbName}`);

    // 创建用户表
    console.log('📋 创建 users 表...');
    await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(36) NOT NULL PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL,
        password VARCHAR(255) NOT NULL,
        nickname VARCHAR(50) DEFAULT NULL,
        avatar VARCHAR(255) DEFAULT NULL,
        height DECIMAL(5,2) DEFAULT NULL,
        gender ENUM('male', 'female', 'other') DEFAULT NULL,
        birthday DATE DEFAULT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        deleted_at DATETIME DEFAULT NULL,
        UNIQUE KEY uk_username (username),
        UNIQUE KEY uk_email (email),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ users 表创建成功');

    // 创建健康记录表
    console.log('📋 创建 health_records 表...');
    await connection.query(`
      CREATE TABLE IF NOT EXISTS health_records (
        id VARCHAR(36) NOT NULL PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        type ENUM('weight', 'steps', 'blood_pressure_sys', 'blood_pressure_dia', 'heart_rate', 'sleep', 'water', 'calories') NOT NULL,
        value DECIMAL(10,2) NOT NULL,
        note VARCHAR(500) DEFAULT NULL,
        record_date DATE NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_user_type (user_id, type),
        INDEX idx_user_date (user_id, record_date),
        INDEX idx_record_date (record_date),
        CONSTRAINT fk_health_records_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ health_records 表创建成功');

    // 创建用户目标表
    console.log('📋 创建 user_goals 表...');
    await connection.query(`
      CREATE TABLE IF NOT EXISTS user_goals (
        id VARCHAR(36) NOT NULL PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        steps_goal INT DEFAULT 8000,
        water_goal INT DEFAULT 2000,
        sleep_goal DECIMAL(4,2) DEFAULT 8.00,
        calories_goal INT DEFAULT 2000,
        weight_goal DECIMAL(5,2) DEFAULT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY uk_user_id (user_id),
        CONSTRAINT fk_user_goals_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ user_goals 表创建成功');

    // 创建健康百科表
    console.log('📋 创建 health_tips 表...');
    await connection.query(`
      CREATE TABLE IF NOT EXISTS health_tips (
        id VARCHAR(36) NOT NULL PRIMARY KEY,
        title VARCHAR(200) NOT NULL,
        content TEXT NOT NULL,
        category VARCHAR(50) NOT NULL,
        image_url VARCHAR(255) DEFAULT NULL,
        sort_order INT DEFAULT 0,
        is_active TINYINT(1) DEFAULT 1,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_category (category),
        INDEX idx_is_active (is_active),
        INDEX idx_sort_order (sort_order)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ health_tips 表创建成功');

    // 创建运动建议表
    console.log('📋 创建 exercise_advice 表...');
    await connection.query(`
      CREATE TABLE IF NOT EXISTS exercise_advice (
        id VARCHAR(36) NOT NULL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT NOT NULL,
        weather ENUM('all', 'sunny', 'cloudy', 'rainy', 'snowy', 'hot', 'cold') DEFAULT 'all',
        time_slot ENUM('all', 'morning', 'afternoon', 'evening', 'night') DEFAULT 'all',
        intensity ENUM('low', 'medium', 'high') DEFAULT 'medium',
        duration INT DEFAULT 30,
        calories_burned INT DEFAULT 0,
        image_url VARCHAR(255) DEFAULT NULL,
        sort_order INT DEFAULT 0,
        is_active TINYINT(1) DEFAULT 1,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_weather (weather),
        INDEX idx_time_slot (time_slot),
        INDEX idx_intensity (intensity),
        INDEX idx_is_active (is_active)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('✅ exercise_advice 表创建成功');

    console.log('\n========================================');
    console.log('🎉 数据库初始化完成!');
    console.log('========================================');
    console.log('\n下一步: 运行 npm run seed 导入初始数据\n');

  } catch (error) {
    console.error('❌ 数据库初始化失败:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

initDatabase();
