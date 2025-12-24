/**
 * 健康分析服务
 * 提供 BMI 计算、健康评估、趋势分析等功能
 */

const moment = require('moment');
const config = require('../config');
const { HealthRecordModel, UserModel, UserGoalModel } = require('../models');

/**
 * 安全地将值转换为数字
 */
function toNumber(value, defaultValue = 0) {
  if (value === null || value === undefined) return defaultValue;
  const num = parseFloat(value);
  return isNaN(num) ? defaultValue : num;
}

/**
 * 安全地格式化数字为指定小数位
 */
function formatNumber(value, decimals = 1) {
  const num = toNumber(value);
  return parseFloat(num.toFixed(decimals));
}

/**
 * 计算 BMI 指数
 * BMI = 体重(kg) / 身高(m)²
 */
function calculateBMI(weight, heightCm) {
  if (!weight || !heightCm || heightCm <= 0) {
    return null;
  }
  const heightM = heightCm / 100;
  return parseFloat((weight / (heightM * heightM)).toFixed(1));
}

/**
 * 获取 BMI 分类和建议
 */
function getBMICategory(bmi) {
  if (bmi === null) return null;

  const { bmiCategories } = config;
  
  if (bmi < bmiCategories.UNDERWEIGHT.max) {
    return { ...bmiCategories.UNDERWEIGHT, bmi };
  } else if (bmi < bmiCategories.NORMAL.max) {
    return { ...bmiCategories.NORMAL, bmi };
  } else if (bmi < bmiCategories.OVERWEIGHT.max) {
    return { ...bmiCategories.OVERWEIGHT, bmi };
  } else {
    return { ...bmiCategories.OBESE, bmi };
  }
}

/**
 * 获取用户完整健康分析报告
 */
async function getHealthAnalysis(userId) {
  // 获取用户基本信息
  const user = await UserModel.findById(userId);
  if (!user) {
    throw new Error('用户不存在');
  }

  // 获取最近的体重记录
  const latestRecords = await HealthRecordModel.getLatestByTypes(userId, [
    'weight', 'steps', 'heart_rate', 'blood_pressure_sys', 'blood_pressure_dia', 'sleep', 'water', 'calories'
  ]);

  const latestWeight = latestRecords.find(r => r.type === 'weight')?.value;
  const latestSteps = latestRecords.find(r => r.type === 'steps')?.value;
  const latestHeartRate = latestRecords.find(r => r.type === 'heart_rate')?.value;
  const latestSysBP = latestRecords.find(r => r.type === 'blood_pressure_sys')?.value;
  const latestDiaBP = latestRecords.find(r => r.type === 'blood_pressure_dia')?.value;
  const latestSleep = latestRecords.find(r => r.type === 'sleep')?.value;

  // 计算 BMI
  const bmi = calculateBMI(latestWeight, user.height);
  const bmiCategory = getBMICategory(bmi);

  // 获取过去 7 天和 30 天的统计
  const today = moment().format('YYYY-MM-DD');
  const weekAgo = moment().subtract(7, 'days').format('YYYY-MM-DD');
  const monthAgo = moment().subtract(30, 'days').format('YYYY-MM-DD');

  const weeklySteps = await HealthRecordModel.getStatistics(userId, 'steps', weekAgo, today);
  const monthlySteps = await HealthRecordModel.getStatistics(userId, 'steps', monthAgo, today);
  const weeklyWeight = await HealthRecordModel.getStatistics(userId, 'weight', weekAgo, today);
  const monthlyWeight = await HealthRecordModel.getStatistics(userId, 'weight', monthAgo, today);

  // 获取用户目标
  const goals = await UserGoalModel.findByUserIdWithDefaults(userId);

  // 计算健康评分 (0-100)
  const healthScore = calculateHealthScore({
    bmi,
    latestSteps,
    latestSleep,
    latestHeartRate,
    latestSysBP,
    latestDiaBP,
    goals
  });

  // 生成健康建议
  const recommendations = generateRecommendations({
    bmiCategory,
    latestSteps,
    latestSleep,
    latestHeartRate,
    bloodPressure: latestSysBP && latestDiaBP ? { sys: latestSysBP, dia: latestDiaBP } : null,
    goals
  });

  return {
    user: {
      nickname: user.nickname,
      height: user.height,
      gender: user.gender
    },
    currentStatus: {
      weight: latestWeight,
      steps: latestSteps,
      heartRate: latestHeartRate,
      bloodPressure: latestSysBP && latestDiaBP ? `${latestSysBP}/${latestDiaBP}` : null,
      sleep: latestSleep
    },
    bmiAnalysis: bmiCategory,
    statistics: {
      weekly: {
        avgSteps: weeklySteps?.avg_value ? Math.round(toNumber(weeklySteps.avg_value)) : 0,
        totalSteps: toNumber(weeklySteps?.total_value, 0),
        avgWeight: weeklyWeight?.avg_value ? formatNumber(weeklyWeight.avg_value, 1) : 0
      },
      monthly: {
        avgSteps: monthlySteps?.avg_value ? Math.round(toNumber(monthlySteps.avg_value)) : 0,
        totalSteps: toNumber(monthlySteps?.total_value, 0),
        avgWeight: monthlyWeight?.avg_value ? formatNumber(monthlyWeight.avg_value, 1) : 0,
        weightChange: monthlyWeight?.max_value && monthlyWeight?.min_value 
          ? formatNumber(toNumber(monthlyWeight.max_value) - toNumber(monthlyWeight.min_value), 1)
          : null
      }
    },
    goals,
    healthScore,
    recommendations,
    analyzedAt: new Date().toISOString()
  };
}

/**
 * 计算综合健康评分
 */
function calculateHealthScore(data) {
  let score = 60; // 基础分
  const { bmi, latestSteps, latestSleep, latestHeartRate, latestSysBP, latestDiaBP, goals } = data;

  // BMI 评分 (最多 +20)
  if (bmi) {
    if (bmi >= 18.5 && bmi < 24) {
      score += 20;
    } else if (bmi >= 17 && bmi < 28) {
      score += 10;
    }
  }

  // 步数评分 (最多 +15)
  if (latestSteps) {
    const stepsGoal = goals?.stepsGoal || 8000;
    const stepsRatio = latestSteps / stepsGoal;
    if (stepsRatio >= 1) {
      score += 15;
    } else if (stepsRatio >= 0.7) {
      score += 10;
    } else if (stepsRatio >= 0.5) {
      score += 5;
    }
  }

  // 睡眠评分 (最多 +10)
  if (latestSleep) {
    if (latestSleep >= 7 && latestSleep <= 9) {
      score += 10;
    } else if (latestSleep >= 6 && latestSleep <= 10) {
      score += 5;
    }
  }

  // 心率评分 (最多 +5)
  if (latestHeartRate) {
    if (latestHeartRate >= 60 && latestHeartRate <= 80) {
      score += 5;
    } else if (latestHeartRate >= 50 && latestHeartRate <= 100) {
      score += 2;
    }
  }

  // 血压评分 (最多 +5)
  if (latestSysBP && latestDiaBP) {
    if (latestSysBP < 120 && latestDiaBP < 80) {
      score += 5;
    } else if (latestSysBP < 140 && latestDiaBP < 90) {
      score += 2;
    }
  }

  return Math.min(100, Math.max(0, score));
}

/**
 * 生成个性化健康建议
 */
function generateRecommendations(data) {
  const recommendations = [];
  const { bmiCategory, latestSteps, latestSleep, latestHeartRate, bloodPressure, goals } = data;

  // BMI 相关建议
  if (bmiCategory) {
    if (bmiCategory.label === '偏瘦') {
      recommendations.push({
        category: '体重管理',
        priority: 'medium',
        advice: '建议适当增加营养摄入，多吃高蛋白食物，配合力量训练增肌。'
      });
    } else if (bmiCategory.label === '偏胖' || bmiCategory.label === '肥胖') {
      recommendations.push({
        category: '体重管理',
        priority: 'high',
        advice: bmiCategory.advice + ' 建议每周运动至少150分钟。'
      });
    }
  }

  // 步数建议
  if (latestSteps !== null && latestSteps !== undefined) {
    const stepsGoal = goals?.stepsGoal || 8000;
    if (latestSteps < stepsGoal * 0.5) {
      recommendations.push({
        category: '运动建议',
        priority: 'high',
        advice: `您的步数距离目标还有较大差距，建议从每天增加1000步开始，逐步达到${stepsGoal}步的目标。`
      });
    } else if (latestSteps < stepsGoal) {
      recommendations.push({
        category: '运动建议',
        priority: 'medium',
        advice: `继续保持！您距离每日${stepsGoal}步的目标只差${stepsGoal - latestSteps}步了。`
      });
    }
  }

  // 睡眠建议
  if (latestSleep !== null && latestSleep !== undefined) {
    if (latestSleep < 6) {
      recommendations.push({
        category: '睡眠管理',
        priority: 'high',
        advice: '您的睡眠时间不足，长期睡眠不足会影响免疫力和代谢。建议每天保证7-8小时睡眠。'
      });
    } else if (latestSleep > 10) {
      recommendations.push({
        category: '睡眠管理',
        priority: 'medium',
        advice: '睡眠时间过长可能表示睡眠质量不佳或身体不适，建议关注睡眠质量并咨询医生。'
      });
    }
  }

  // 心率建议
  if (latestHeartRate !== null && latestHeartRate !== undefined) {
    if (latestHeartRate > 100) {
      recommendations.push({
        category: '心血管健康',
        priority: 'high',
        advice: '您的静息心率偏高，建议增加有氧运动并减少咖啡因摄入。如持续偏高请咨询医生。'
      });
    }
  }

  // 血压建议
  if (bloodPressure) {
    if (bloodPressure.sys >= 140 || bloodPressure.dia >= 90) {
      recommendations.push({
        category: '血压管理',
        priority: 'high',
        advice: '您的血压偏高，建议减少盐分摄入，保持规律运动，并定期监测。如持续偏高请就医。'
      });
    }
  }

  // 如果没有特别建议，给予鼓励
  if (recommendations.length === 0) {
    recommendations.push({
      category: '综合评价',
      priority: 'low',
      advice: '您的各项健康指标都很不错！继续保持健康的生活方式。'
    });
  }

  return recommendations;
}

/**
 * 获取趋势数据
 */
async function getTrendData(userId, type, period = 'week') {
  const today = moment().format('YYYY-MM-DD');
  let startDate;

  switch (period) {
    case 'week':
      startDate = moment().subtract(7, 'days').format('YYYY-MM-DD');
      break;
    case 'month':
      startDate = moment().subtract(30, 'days').format('YYYY-MM-DD');
      break;
    case 'quarter':
      startDate = moment().subtract(90, 'days').format('YYYY-MM-DD');
      break;
    default:
      startDate = moment().subtract(7, 'days').format('YYYY-MM-DD');
  }

  const dailyData = await HealthRecordModel.getDailySummary(userId, startDate, today);
  
  // 过滤指定类型的数据
  const filteredData = dailyData.filter(d => d.type === type);
  
  return {
    type,
    period,
    startDate,
    endDate: today,
    data: filteredData.map(d => ({
      date: moment(d.record_date).format('YYYY-MM-DD'),
      value: type === 'steps' || type === 'water' || type === 'calories' 
        ? parseFloat(d.total_value) || 0
        : parseFloat(parseFloat(d.avg_value).toFixed(1)) || 0,
      count: parseInt(d.count) || 0
    }))
  };
}

module.exports = {
  calculateBMI,
  getBMICategory,
  getHealthAnalysis,
  calculateHealthScore,
  generateRecommendations,
  getTrendData
};
