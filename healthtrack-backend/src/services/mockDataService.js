/**
 * 模拟数据生成服务
 * 为新用户自动生成30天的历史健康数据
 */

const moment = require('moment');
const { HealthRecordModel } = require('../models');

/**
 * 生成指定范围内的随机数
 */
function randomBetween(min, max, decimals = 0) {
  const value = Math.random() * (max - min) + min;
  return decimals > 0 ? parseFloat(value.toFixed(decimals)) : Math.floor(value);
}

/**
 * 根据日期生成符合真实规律的数据
 */
function generateDayPattern(dayOfWeek) {
  // 周末步数通常较少
  const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
  return {
    stepsMultiplier: isWeekend ? 0.7 : 1.0,
    sleepMultiplier: isWeekend ? 1.1 : 1.0
  };
}

/**
 * 为用户生成模拟健康数据
 * @param {string} userId - 用户ID
 * @param {Object} options - 配置选项
 */
async function generateMockDataForUser(userId, options = {}) {
  const {
    days = 30,           // 生成天数
    baseWeight = 70,     // 基础体重
    baseSteps = 7000,    // 基础步数
    includeAllTypes = true // 是否包含所有数据类型
  } = options;

  const records = [];
  const today = moment().startOf('day');

  for (let i = days; i > 0; i--) {
    const date = today.clone().subtract(i, 'days');
    const dateStr = date.format('YYYY-MM-DD');
    const dayOfWeek = date.day();
    const pattern = generateDayPattern(dayOfWeek);

    // 体重数据 - 模拟小幅波动，整体趋势平稳或略微变化
    const weightTrend = (days - i) * 0.01; // 轻微减重趋势
    records.push({
      userId,
      type: 'weight',
      value: parseFloat((baseWeight - weightTrend + randomBetween(-0.5, 0.5, 1)).toFixed(1)),
      recordDate: dateStr,
      note: null
    });

    // 步数数据
    records.push({
      userId,
      type: 'steps',
      value: Math.floor((baseSteps + randomBetween(-2000, 3000)) * pattern.stepsMultiplier),
      recordDate: dateStr,
      note: null
    });

    if (includeAllTypes) {
      // 心率数据 (正常范围 60-100)
      records.push({
        userId,
        type: 'heart_rate',
        value: randomBetween(65, 85),
        recordDate: dateStr,
        note: null
      });

      // 收缩压 (正常范围 90-139)
      records.push({
        userId,
        type: 'blood_pressure_sys',
        value: randomBetween(110, 130),
        recordDate: dateStr,
        note: null
      });

      // 舒张压 (正常范围 60-89)
      records.push({
        userId,
        type: 'blood_pressure_dia',
        value: randomBetween(70, 85),
        recordDate: dateStr,
        note: null
      });

      // 睡眠时长 (小时)
      records.push({
        userId,
        type: 'sleep',
        value: parseFloat((randomBetween(6, 9, 1) * pattern.sleepMultiplier).toFixed(1)),
        recordDate: dateStr,
        note: null
      });

      // 饮水量 (ml)
      records.push({
        userId,
        type: 'water',
        value: randomBetween(1200, 2500),
        recordDate: dateStr,
        note: null
      });

      // 卡路里摄入
      records.push({
        userId,
        type: 'calories',
        value: randomBetween(1500, 2500),
        recordDate: dateStr,
        note: null
      });
    }
  }

  // 批量插入数据库
  const insertedCount = await HealthRecordModel.createMany(records);
  
  return {
    success: true,
    insertedCount,
    message: `成功生成 ${insertedCount} 条模拟数据`
  };
}

/**
 * 为演示模式生成特殊数据
 * 数据更具规律性，便于展示趋势
 */
async function generateDemoData(userId) {
  const records = [];
  const today = moment().startOf('day');
  const days = 30;

  // 设置一个明显的减重趋势
  const startWeight = 75;
  const weightLossPerDay = 0.05;

  for (let i = days; i > 0; i--) {
    const date = today.clone().subtract(i, 'days');
    const dateStr = date.format('YYYY-MM-DD');
    const progress = (days - i) / days;

    // 体重 - 明显的下降趋势
    records.push({
      userId,
      type: 'weight',
      value: parseFloat((startWeight - (days - i) * weightLossPerDay + randomBetween(-0.2, 0.2, 1)).toFixed(1)),
      recordDate: dateStr
    });

    // 步数 - 逐渐增加的趋势
    const baseSteps = 5000 + progress * 3000;
    records.push({
      userId,
      type: 'steps',
      value: Math.floor(baseSteps + randomBetween(-500, 1000)),
      recordDate: dateStr
    });

    // 心率 - 逐渐改善
    records.push({
      userId,
      type: 'heart_rate',
      value: Math.floor(80 - progress * 10 + randomBetween(-3, 3)),
      recordDate: dateStr
    });

    // 睡眠 - 逐渐改善
    records.push({
      userId,
      type: 'sleep',
      value: parseFloat((6.5 + progress * 1.5 + randomBetween(-0.3, 0.3, 1)).toFixed(1)),
      recordDate: dateStr
    });
  }

  const insertedCount = await HealthRecordModel.createMany(records);
  
  return {
    success: true,
    insertedCount,
    message: `演示数据生成成功，共 ${insertedCount} 条记录`,
    dataDescription: {
      weight: '从 75kg 逐步减至约 73.5kg',
      steps: '从约 5000 步增至约 8000 步',
      heartRate: '从约 80 bpm 改善至约 70 bpm',
      sleep: '从约 6.5 小时增至约 8 小时'
    }
  };
}

module.exports = {
  generateMockDataForUser,
  generateDemoData,
  randomBetween
};
