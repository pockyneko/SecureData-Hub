/**
 * 模拟数据生成服务
 * 为新用户自动生成30天的历史健康数据
 * 支持基于用户健康档案的个性化数据生成
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
 * 根据健康档案获取个性化的健康指标基准值
 * @param {Object} healthProfile - 用户健康档案
 */
function getPersonalizedBaselines(healthProfile = {}) {
  const {
    ageGroup = 'adult',
    activityLevel = 'moderately_active',
    hasCardiovascularIssues = false,
    hasDiabetes = false,
    hasJointIssues = false,
    isPregnant = false,
    isRecovering = false
  } = healthProfile;

  // 基础基准值
  let baselines = {
    steps: 10000,
    heartRateMin: 60,
    heartRateMax: 80,
    sleep: 8,
    water: 2500,
    weight: 70,
    bloodPressureSys: 120,
    bloodPressureDia: 80
  };

  // 根据年龄段调整
  const ageAdjustments = {
    'child': {
      steps: 8000,
      heartRateMin: 70,
      heartRateMax: 100,
      sleep: 9.5,
      water: 1500
    },
    'teen': {
      steps: 9000,
      heartRateMin: 60,
      heartRateMax: 100,
      sleep: 9,
      water: 2000
    },
    'adult': {
      steps: 10000,
      heartRateMin: 60,
      heartRateMax: 85,
      sleep: 8,
      water: 2500
    },
    'middle_age': {
      steps: 8000,
      heartRateMin: 55,
      heartRateMax: 80,
      sleep: 7.5,
      water: 2200,
      bloodPressureSys: 130,
      bloodPressureDia: 85
    },
    'senior': {
      steps: 6000,
      heartRateMin: 50,
      heartRateMax: 75,
      sleep: 7,
      water: 2000,
      bloodPressureSys: 140,
      bloodPressureDia: 90
    }
  };

  // 根据运动水平调整
  const activityAdjustments = {
    'sedentary': { steps: 0.5, water: 0.9 },
    'lightly_active': { steps: 0.7, water: 0.95 },
    'moderately_active': { steps: 1.0, water: 1.0 },
    'very_active': { steps: 1.3, water: 1.1 },
    'extremely_active': { steps: 1.6, water: 1.3 }
  };

  // 特殊情况调整
  const specialAdjustments = {
    cardiovascular: { steps: 0.8, heartRateMin: 5, water: 0.9 },
    diabetes: { steps: 1.1, water: 0.85 },
    jointIssues: { steps: 0.6, heartRateMax: -5 },
    pregnant: { steps: 0.6, sleep: 1.1, water: 1.2 },
    recovering: { steps: 0.5, sleep: 1.2, water: 1.0 }
  };

  // 应用年龄段调整
  if (ageAdjustments[ageGroup]) {
    baselines = { ...baselines, ...ageAdjustments[ageGroup] };
  }

  // 应用运动水平调整
  const activity = activityAdjustments[activityLevel] || activityAdjustments['moderately_active'];
  baselines.steps = Math.floor(baselines.steps * activity.steps);
  baselines.water = Math.floor(baselines.water * activity.water);

  // 应用特殊情况调整
  if (hasCardiovascularIssues) {
    baselines.steps = Math.floor(baselines.steps * specialAdjustments.cardiovascular.steps);
    baselines.heartRateMin += specialAdjustments.cardiovascular.heartRateMin;
    baselines.water = Math.floor(baselines.water * specialAdjustments.cardiovascular.water);
  }

  if (hasDiabetes) {
    baselines.steps = Math.floor(baselines.steps * specialAdjustments.diabetes.steps);
    baselines.water = Math.floor(baselines.water * specialAdjustments.diabetes.water);
  }

  if (hasJointIssues) {
    baselines.steps = Math.floor(baselines.steps * specialAdjustments.jointIssues.steps);
    baselines.heartRateMax += specialAdjustments.jointIssues.heartRateMax;
  }

  if (isPregnant) {
    baselines.steps = Math.floor(baselines.steps * specialAdjustments.pregnant.steps);
    baselines.sleep = parseFloat((baselines.sleep * specialAdjustments.pregnant.sleep).toFixed(1));
    baselines.water = Math.floor(baselines.water * specialAdjustments.pregnant.water);
  }

  if (isRecovering) {
    baselines.steps = Math.floor(baselines.steps * specialAdjustments.recovering.steps);
    baselines.sleep = parseFloat((baselines.sleep * specialAdjustments.recovering.sleep).toFixed(1));
  }

  return baselines;
}

/**
 * 为用户生成模拟健康数据
 * @param {string} userId - 用户ID
 * @param {Object} options - 配置选项
 * @param {number} options.days - 生成天数（默认30）
 * @param {Object} options.healthProfile - 用户健康档案，用于个性化数据生成
 * @param {boolean} options.includeAllTypes - 是否包含所有数据类型
 * @param {number} options.baseWeight - 基础体重（会被healthProfile覆盖）
 */
async function generateMockDataForUser(userId, options = {}) {
  const {
    days = 30,
    healthProfile = {},
    includeAllTypes = true,
    baseWeight = 70
  } = options;

  // 根据健康档案获取个性化基准值
  const baselines = getPersonalizedBaselines(healthProfile);

  const records = [];
  const today = moment().startOf('day');

  for (let i = days; i > 0; i--) {
    const date = today.clone().subtract(i, 'days');
    const dateStr = date.format('YYYY-MM-DD');
    const dayOfWeek = date.day();
    const pattern = generateDayPattern(dayOfWeek);

    // 体重数据 - 使用healthProfile中的体重或基础体重
    const profileWeight = healthProfile.weight || baseWeight;
    const weightTrend = (days - i) * 0.01; // 轻微减重趋势
    records.push({
      userId,
      type: 'weight',
      value: parseFloat((profileWeight - weightTrend + randomBetween(-0.5, 0.5, 1)).toFixed(1)),
      recordDate: dateStr,
      note: null
    });

    // 步数数据 - 使用个性化基准值
    records.push({
      userId,
      type: 'steps',
      value: Math.floor((baselines.steps + randomBetween(-1000, 2000)) * pattern.stepsMultiplier),
      recordDate: dateStr,
      note: null
    });

    if (includeAllTypes) {
      // 心率数据 - 使用个性化范围
      records.push({
        userId,
        type: 'heart_rate',
        value: randomBetween(baselines.heartRateMin, baselines.heartRateMax),
        recordDate: dateStr,
        note: null
      });

      // 收缩压 - 使用个性化标准
      const sysTolerance = baselines.bloodPressureSys > 130 ? 15 : 10;
      records.push({
        userId,
        type: 'blood_pressure_sys',
        value: randomBetween(baselines.bloodPressureSys - 5, baselines.bloodPressureSys + sysTolerance),
        recordDate: dateStr,
        note: null
      });

      // 舒张压 - 使用个性化标准
      const diaTolerance = baselines.bloodPressureDia > 85 ? 10 : 8;
      records.push({
        userId,
        type: 'blood_pressure_dia',
        value: randomBetween(baselines.bloodPressureDia - 3, baselines.bloodPressureDia + diaTolerance),
        recordDate: dateStr,
        note: null
      });

      // 睡眠时长 (小时) - 使用个性化目标
      records.push({
        userId,
        type: 'sleep',
        value: parseFloat((baselines.sleep + randomBetween(-0.5, 0.5, 1) * pattern.sleepMultiplier).toFixed(1)),
        recordDate: dateStr,
        note: null
      });

      // 饮水量 (ml) - 使用个性化目标
      const waterVariation = Math.floor(baselines.water * 0.15);
      records.push({
        userId,
        type: 'water',
        value: randomBetween(baselines.water - waterVariation, baselines.water + waterVariation),
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
    message: `成功生成 ${insertedCount} 条模拟数据`,
    dataProfile: {
      profileApplied: Object.keys(healthProfile).length > 0,
      baselines: baselines
    }
  };
}

/**
 * 为演示模式生成特殊数据
 * 数据更具规律性，便于展示趋势
 * @param {string} userId - 用户ID
 * @param {Object} healthProfile - 用户健康档案
 */
async function generateDemoData(userId, healthProfile = {}) {
  const records = [];
  const today = moment().startOf('day');
  const days = 30;

  // 获取个性化基准值
  const baselines = getPersonalizedBaselines(healthProfile);

  // 设置一个明显的减重趋势
  const profileWeight = healthProfile.weight || 75;
  const weightLossPerDay = 0.05;

  for (let i = days; i > 0; i--) {
    const date = today.clone().subtract(i, 'days');
    const dateStr = date.format('YYYY-MM-DD');
    const progress = (days - i) / days;

    // 体重 - 明显的下降趋势
    records.push({
      userId,
      type: 'weight',
      value: parseFloat((profileWeight - (days - i) * weightLossPerDay + randomBetween(-0.2, 0.2, 1)).toFixed(1)),
      recordDate: dateStr
    });

    // 步数 - 根据基线逐渐增加的趋势
    const baseStepsMin = baselines.steps * 0.7;
    const baseStepsMax = baselines.steps * 1.2;
    const progressSteps = baseStepsMin + (baseStepsMax - baseStepsMin) * progress;
    records.push({
      userId,
      type: 'steps',
      value: Math.floor(progressSteps + randomBetween(-300, 500)),
      recordDate: dateStr
    });

    // 心率 - 逐渐改善（降低）
    const heartRateImprovement = baselines.heartRateMax - baselines.heartRateMin;
    const progressHeartRate = baselines.heartRateMax - heartRateImprovement * progress;
    records.push({
      userId,
      type: 'heart_rate',
      value: Math.floor(progressHeartRate + randomBetween(-2, 2)),
      recordDate: dateStr
    });

    // 睡眠 - 逐渐改善
    const progressSleep = baselines.sleep * 0.8 + baselines.sleep * 0.2 * progress + randomBetween(-0.3, 0.3, 1);
    records.push({
      userId,
      type: 'sleep',
      value: parseFloat(progressSleep.toFixed(1)),
      recordDate: dateStr
    });

    // 血压 - 缓慢改善
    const sysImprovement = baselines.bloodPressureSys > 130 ? 10 : 5;
    const diaImprovement = baselines.bloodPressureDia > 85 ? 5 : 3;
    records.push({
      userId,
      type: 'blood_pressure_sys',
      value: Math.floor(baselines.bloodPressureSys - sysImprovement * progress + randomBetween(-2, 2)),
      recordDate: dateStr
    });

    records.push({
      userId,
      type: 'blood_pressure_dia',
      value: Math.floor(baselines.bloodPressureDia - diaImprovement * progress + randomBetween(-1, 1)),
      recordDate: dateStr
    });

    // 饮水量 - 逐渐增加
    const waterImprovement = baselines.water * 0.2;
    const progressWater = baselines.water * 0.8 + waterImprovement * progress;
    records.push({
      userId,
      type: 'water',
      value: Math.floor(progressWater + randomBetween(-100, 100)),
      recordDate: dateStr
    });

    // 卡路里 - 相对稳定
    records.push({
      userId,
      type: 'calories',
      value: randomBetween(1500, 2500),
      recordDate: dateStr
    });
  }

  const insertedCount = await HealthRecordModel.createMany(records);
  
  return {
    success: true,
    insertedCount,
    message: `演示数据生成成功，共 ${insertedCount} 条记录`,
    dataDescription: {
      weight: `从 ${profileWeight}kg 逐步减至约 ${(profileWeight - days * weightLossPerDay).toFixed(1)}kg`,
      steps: `从约 ${Math.floor(baselines.steps * 0.7)} 步增至约 ${Math.floor(baselines.steps * 1.2)} 步`,
      heartRate: `从约 ${baselines.heartRateMax} bpm 改善至约 ${Math.floor(baselines.heartRateMin + (baselines.heartRateMax - baselines.heartRateMin) * 0.3)} bpm`,
      sleep: `从约 ${(baselines.sleep * 0.8).toFixed(1)} 小时增至约 ${baselines.sleep.toFixed(1)} 小时`,
      bloodPressure: `从约 ${baselines.bloodPressureSys}/${baselines.bloodPressureDia} 逐步改善`,
      water: `从约 ${Math.floor(baselines.water * 0.8)}ml 增至约 ${baselines.water}ml`
    },
    profileApplied: Object.keys(healthProfile).length > 0,
    baselines: baselines
  };
}

module.exports = {
  generateMockDataForUser,
  generateDemoData,
  randomBetween,
  getPersonalizedBaselines
};
