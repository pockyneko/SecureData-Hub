/**
 * HealthTrack 配置文件
 * 集中管理所有系统配置
 */

require('dotenv').config();

module.exports = {
  // 服务器配置
  server: {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development'
  },

  // 数据库配置
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'healthtrack',
    connectionLimit: 10,
    waitForConnections: true,
    queueLimit: 0
  },

  // JWT 配置
  jwt: {
    secret: process.env.JWT_SECRET || 'default_jwt_secret_change_me',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'default_refresh_secret',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d'
  },

  // 文件上传配置
  upload: {
    dir: process.env.UPLOAD_DIR || './uploads',
    maxSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024 // 5MB
  },

  // 跨域配置
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true
  },

  // 健康数据类型
  healthDataTypes: {
    WEIGHT: 'weight',           // 体重 (kg)
    STEPS: 'steps',             // 步数
    BLOOD_PRESSURE_SYS: 'blood_pressure_sys',   // 收缩压 (mmHg)
    BLOOD_PRESSURE_DIA: 'blood_pressure_dia',   // 舒张压 (mmHg)
    HEART_RATE: 'heart_rate',   // 心率 (bpm)
    SLEEP: 'sleep',             // 睡眠时长 (小时)
    WATER: 'water',             // 饮水量 (ml)
    CALORIES: 'calories'        // 卡路里摄入 (kcal)
  },

  // BMI 分类标准
  bmiCategories: {
    UNDERWEIGHT: { min: 0, max: 18.5, label: '偏瘦', advice: '建议适当增加营养摄入' },
    NORMAL: { min: 18.5, max: 24, label: '正常', advice: '继续保持健康的生活方式' },
    OVERWEIGHT: { min: 24, max: 28, label: '偏胖', advice: '建议增加运动，控制饮食' },
    OBESE: { min: 28, max: 100, label: '肥胖', advice: '建议咨询医生，制定减重计划' }
  },

  // 健康目标默认值
  defaultGoals: {
    steps: 8000,      // 每日步数目标
    water: 2000,      // 每日饮水目标 (ml)
    sleep: 8,         // 每日睡眠目标 (小时)
    calories: 2000    // 每日卡路里目标 (kcal)
  }
};
