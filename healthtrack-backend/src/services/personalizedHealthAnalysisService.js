/**
 * 个性化健康分析服务
 * 基于用户个人特征提供定制化的健康评估和建议
 */

const moment = require('moment');
const config = require('../config');
const { HealthRecordModel, UserModel, UserGoalModel, UserHealthProfileModel } = require('../models');

/**
 * 安全地将值转换为数字
 */
function toNumber(value, defaultValue = 0) {
  if (value === null || value === undefined) return defaultValue;
  const num = parseFloat(value);
  return isNaN(num) ? defaultValue : num;
}

/**
 * 计算 BMI 指数
 */
function calculateBMI(weight, heightCm) {
  if (!weight || !heightCm || heightCm <= 0) {
    return null;
  }
  const heightM = heightCm / 100;
  return parseFloat((weight / (heightM * heightM)).toFixed(1));
}

/**
 * 获取个性化的 BMI 分类
 */
function getPersonalizedBMICategory(bmi, standards) {
  if (bmi === null || !standards) return null;

  const { bmi_optimal_min: optimalMin = 18.5, bmi_optimal_max: optimalMax = 24 } = standards;

  if (bmi < optimalMin) {
    return {
      label: '偏瘦',
      status: 'underweight',
      bmi,
      min: optimalMin,
      max: optimalMax,
      advice: `您的BMI为${bmi}，低于最适范围${optimalMin}-${optimalMax}。建议增加营养摄入。`
    };
  } else if (bmi >= optimalMin && bmi <= optimalMax) {
    return {
      label: '正常',
      status: 'normal',
      bmi,
      min: optimalMin,
      max: optimalMax,
      advice: `您的BMI为${bmi}，处于健康范围${optimalMin}-${optimalMax}。继续保持！`
    };
  } else if (bmi <= optimalMax + 5) {
    return {
      label: '偏胖',
      status: 'overweight',
      bmi,
      min: optimalMin,
      max: optimalMax,
      advice: `您的BMI为${bmi}，已超过最适范围${optimalMin}-${optimalMax}。建议增加运动。`
    };
  } else {
    return {
      label: '肥胖',
      status: 'obese',
      bmi,
      min: optimalMin,
      max: optimalMax,
      advice: `您的BMI为${bmi}，显著高于最适范围${optimalMin}-${optimalMax}。建议医学干预。`
    };
  }
}

/**
 * 获取个性化的步数评估
 */
function getPersonalizedStepsAssessment(steps, standards, goals) {
  if (steps === null || !standards) {
    return {
      current: steps,
      status: 'unknown'
    };
  }

  const {
    daily_steps_min: minSteps = 5000,
    daily_steps_optimal: optimalSteps = 10000,
    daily_steps_max: maxSteps = 15000
  } = standards;

  const userGoal = goals?.stepsGoal || optimalSteps;

  if (steps < minSteps) {
    const gap = minSteps - steps;
    return {
      current: steps,
      min: minSteps,
      optimal: optimalSteps,
      max: maxSteps,
      userGoal,
      status: 'below_minimum',
      percentage: (steps / minSteps * 100).toFixed(1),
      advice: `您的步数为${steps}，距离最低建议${minSteps}步还差${gap}步。建议逐步增加日常活动量。`,
      priority: 'high'
    };
  } else if (steps < optimalSteps) {
    const gap = optimalSteps - steps;
    return {
      current: steps,
      min: minSteps,
      optimal: optimalSteps,
      max: maxSteps,
      userGoal,
      status: 'below_optimal',
      percentage: (steps / optimalSteps * 100).toFixed(1),
      advice: `您的步数为${steps}，距离最优${optimalSteps}步还差${gap}步。继续加油！`,
      priority: 'medium'
    };
  } else if (steps <= maxSteps) {
    return {
      current: steps,
      min: minSteps,
      optimal: optimalSteps,
      max: maxSteps,
      userGoal,
      status: 'optimal',
      percentage: 100,
      advice: `您的步数为${steps}，已达到最优范围！继续保持健康的运动习惯。`,
      priority: 'low'
    };
  } else {
    return {
      current: steps,
      min: minSteps,
      optimal: optimalSteps,
      max: maxSteps,
      userGoal,
      status: 'excessive',
      percentage: 100,
      advice: `您的步数为${steps}，超过建议最大值${maxSteps}。确保充分休息，避免过度疲劳。`,
      priority: 'medium'
    };
  }
}

/**
 * 获取个性化的心率评估
 */
function getPersonalizedHeartRateAssessment(heartRate, standards) {
  if (heartRate === null || !standards) {
    return {
      current: heartRate,
      status: 'unknown'
    };
  }

  const {
    resting_heart_rate_min: minHR = 60,
    resting_heart_rate_normal: normalHR = 80,
    max_heart_rate: maxHR = 190
  } = standards;

  if (heartRate < minHR) {
    return {
      current: heartRate,
      min: minHR,
      normal: normalHR,
      max: maxHR,
      status: 'very_low',
      advice: `您的静息心率为${heartRate}bpm，非常低，可能表示心肺功能很好（如运动员）或需要医学评估。`,
      priority: 'medium'
    };
  } else if (heartRate <= normalHR) {
    return {
      current: heartRate,
      min: minHR,
      normal: normalHR,
      max: maxHR,
      status: 'normal',
      advice: `您的静息心率为${heartRate}bpm，处于健康范围。`,
      priority: 'low'
    };
  } else {
    const excess = heartRate - normalHR;
    return {
      current: heartRate,
      min: minHR,
      normal: normalHR,
      max: maxHR,
      status: 'elevated',
      advice: `您的静息心率为${heartRate}bpm，比正常范围高${excess}bpm。建议增加有氧运动，减少压力和咖啡因。`,
      priority: 'high'
    };
  }
}

/**
 * 获取个性化的睡眠评估
 */
function getPersonalizedSleepAssessment(sleep, standards) {
  if (sleep === null || !standards) {
    return {
      current: sleep,
      status: 'unknown'
    };
  }

  const {
    sleep_min: minSleep = 7,
    sleep_optimal: optimalSleep = 8,
    sleep_max: maxSleep = 9
  } = standards;

  if (sleep < minSleep) {
    const shortfall = minSleep - sleep;
    return {
      current: sleep,
      min: minSleep,
      optimal: optimalSleep,
      max: maxSleep,
      status: 'insufficient',
      advice: `您的睡眠时间为${sleep}小时，不足${minSleep}小时建议。睡眠不足会影响健康，建议改善睡眠习惯。`,
      priority: 'high'
    };
  } else if (sleep >= minSleep && sleep <= maxSleep) {
    return {
      current: sleep,
      min: minSleep,
      optimal: optimalSleep,
      max: maxSleep,
      status: 'optimal',
      advice: `您的睡眠时间为${sleep}小时，在健康范围内。继续保持良好作息。`,
      priority: 'low'
    };
  } else {
    const excess = sleep - maxSleep;
    return {
      current: sleep,
      min: minSleep,
      optimal: optimalSleep,
      max: maxSleep,
      status: 'excessive',
      advice: `您的睡眠时间为${sleep}小时，超过${maxSleep}小时。过度睡眠可能表示睡眠质量差或身体不适。`,
      priority: 'medium'
    };
  }
}

/**
 * 获取个性化的血压评估
 */
function getPersonalizedBloodPressureAssessment(sys, dia, standards) {
  if ((sys === null || dia === null) || !standards) {
    return {
      current: sys && dia ? `${sys}/${dia}` : null,
      status: 'unknown'
    };
  }

  const {
    blood_pressure_systolic_normal: normalSys = 120,
    blood_pressure_diastolic_normal: normalDia = 80
  } = standards;

  if (sys < normalSys && dia < normalDia) {
    return {
      current: `${sys}/${dia}`,
      normalSys,
      normalDia,
      status: 'optimal',
      advice: `您的血压为${sys}/${dia}mmHg，处于正常范围。很好！`,
      priority: 'low'
    };
  } else if (sys < 140 && dia < 90) {
    const sysDiff = sys - normalSys;
    const diaDiff = dia - normalDia;
    return {
      current: `${sys}/${dia}`,
      normalSys,
      normalDia,
      status: 'elevated',
      advice: `您的血压为${sys}/${dia}mmHg，略高于正常。建议减少盐摄入，增加运动。`,
      priority: 'medium'
    };
  } else {
    return {
      current: `${sys}/${dia}`,
      normalSys,
      normalDia,
      status: 'high',
      advice: `您的血压为${sys}/${dia}mmHg，高于正常范围。建议及时就医并调整生活方式。`,
      priority: 'high'
    };
  }
}

/**
 * 获取个性化的健康分析报告
 */
async function getPersonalizedHealthAnalysis(userId) {
  // 获取用户基本信息
  const user = await UserModel.findById(userId);
  if (!user) {
    throw new Error('用户不存在');
  }

  // 获取用户的健康档案和个性化标准
  const healthProfile = await UserHealthProfileModel.findByUserId(userId);
  const personalizedStandards = await UserHealthProfileModel.getPersonalizedStandards(userId);

  // 如果没有健康档案，自动创建
  if (!healthProfile) {
    await UserHealthProfileModel.initializeForNewUser(userId, user);
  }

  // 获取最近的健康数据
  const latestRecords = await HealthRecordModel.getLatestByTypes(userId, [
    'weight', 'steps', 'heart_rate', 'blood_pressure_sys', 'blood_pressure_dia', 'sleep', 'water'
  ]);

  const latestWeight = latestRecords.find(r => r.type === 'weight')?.value;
  const latestSteps = latestRecords.find(r => r.type === 'steps')?.value;
  const latestHeartRate = latestRecords.find(r => r.type === 'heart_rate')?.value;
  const latestSysBP = latestRecords.find(r => r.type === 'blood_pressure_sys')?.value;
  const latestDiaBP = latestRecords.find(r => r.type === 'blood_pressure_dia')?.value;
  const latestSleep = latestRecords.find(r => r.type === 'sleep')?.value;

  // 计算 BMI
  const bmi = calculateBMI(latestWeight, user.height);
  const bmiCategory = getPersonalizedBMICategory(bmi, personalizedStandards);

  // 获取个性化评估
  const goals = await UserGoalModel.findByUserIdWithDefaults(userId);
  const stepsAssessment = getPersonalizedStepsAssessment(
    latestSteps,
    personalizedStandards,
    goals
  );
  const heartRateAssessment = getPersonalizedHeartRateAssessment(
    latestHeartRate,
    personalizedStandards
  );
  const sleepAssessment = getPersonalizedSleepAssessment(
    latestSleep,
    personalizedStandards
  );
  const bloodPressureAssessment = getPersonalizedBloodPressureAssessment(
    latestSysBP,
    latestDiaBP,
    personalizedStandards
  );

  // 生成个性化建议
  const recommendations = generatePersonalizedRecommendations({
    healthProfile,
    personalizedStandards,
    bmiCategory,
    stepsAssessment,
    heartRateAssessment,
    sleepAssessment,
    bloodPressureAssessment
  });

  // 计算个性化健康评分
  const healthScore = calculatePersonalizedHealthScore({
    bmiCategory,
    stepsAssessment,
    heartRateAssessment,
    sleepAssessment,
    bloodPressureAssessment,
    healthProfile,
    personalizedStandards
  });

  return {
    userInfo: {
      id: user.id,
      nickname: user.nickname,
      height: user.height,
      gender: user.gender,
      ageGroup: personalizedStandards?.age_group,
      activityLevel: personalizedStandards?.activity_level,
      healthCondition: personalizedStandards?.health_condition
    },
    personalizationFactors: {
      hasCardiovascularIssues: healthProfile?.has_cardiovascular_issues || false,
      hasDiabetes: healthProfile?.has_diabetes || false,
      hasJointIssues: healthProfile?.has_joint_issues || false,
      isPregnant: healthProfile?.is_pregnant || false,
      isRecovering: healthProfile?.is_recovering || false,
      doctorNotes: healthProfile?.doctor_notes
    },
    currentStatus: {
      weight: latestWeight,
      steps: latestSteps,
      heartRate: latestHeartRate,
      bloodPressure: latestSysBP && latestDiaBP ? `${latestSysBP}/${latestDiaBP}` : null,
      sleep: latestSleep
    },
    assessments: {
      bmi: bmiCategory,
      steps: stepsAssessment,
      heartRate: heartRateAssessment,
      sleep: sleepAssessment,
      bloodPressure: bloodPressureAssessment
    },
    healthScore,
    recommendations,
    personalizedStandards: {
      recommendedDailySteps: personalizedStandards?.recommended_daily_steps,
      recommendedHeartRateRange: personalizedStandards ? 
        `${personalizedStandards.recommended_heart_rate_min}-${personalizedStandards.recommended_heart_rate_max} bpm` 
        : null,
      recommendedSleepHours: personalizedStandards?.recommended_sleep_hours,
      recommendedWaterMl: personalizedStandards?.recommended_water_ml,
      bmiOptimalRange: personalizedStandards ? 
        `${personalizedStandards.bmi_optimal_min}-${personalizedStandards.bmi_optimal_max}` 
        : null,
      bloodPressureNormal: personalizedStandards ? 
        `${personalizedStandards.blood_pressure_systolic_normal}/${personalizedStandards.blood_pressure_diastolic_normal} mmHg` 
        : null
    },
    analyzedAt: new Date().toISOString()
  };
}

/**
 * 计算个性化健康评分
 */
function calculatePersonalizedHealthScore(data) {
  let score = 60; // 基础分
  const {
    bmiCategory,
    stepsAssessment,
    heartRateAssessment,
    sleepAssessment,
    bloodPressureAssessment,
    healthProfile
  } = data;

  // BMI 评分 (最多 +20)
  if (bmiCategory) {
    if (bmiCategory.status === 'normal') {
      score += 20;
    } else if (bmiCategory.status === 'underweight' || bmiCategory.status === 'overweight') {
      score += 10;
    }
  }

  // 步数评分 (最多 +20，个性化)
  if (stepsAssessment?.status) {
    if (stepsAssessment.status === 'optimal') {
      score += 20;
    } else if (stepsAssessment.status === 'below_optimal') {
      score += 10;
    } else if (stepsAssessment.status === 'below_minimum') {
      score += 5;
    }
  }

  // 睡眠评分 (最多 +15)
  if (sleepAssessment?.status) {
    if (sleepAssessment.status === 'optimal') {
      score += 15;
    } else if (sleepAssessment.status === 'insufficient' || sleepAssessment.status === 'excessive') {
      score += 5;
    }
  }

  // 心率评分 (最多 +15)
  if (heartRateAssessment?.status) {
    if (heartRateAssessment.status === 'normal') {
      score += 15;
    } else if (heartRateAssessment.status === 'very_low' || heartRateAssessment.status === 'elevated') {
      score += 5;
    }
  }

  // 血压评分 (最多 +15)
  if (bloodPressureAssessment?.status) {
    if (bloodPressureAssessment.status === 'optimal') {
      score += 15;
    } else if (bloodPressureAssessment.status === 'elevated') {
      score += 5;
    }
  }

  // 特殊情况扣分
  if (healthProfile) {
    if (healthProfile.has_cardiovascular_issues) score = Math.max(0, score - 10);
    if (healthProfile.has_diabetes) score = Math.max(0, score - 10);
    if (healthProfile.has_joint_issues) score = Math.max(0, score - 5);
    if (healthProfile.is_pregnant) score = Math.max(0, score - 5); // 孕期标准不同，不应过度评分
    if (healthProfile.is_recovering) score = Math.max(0, score - 5);
  }

  return Math.min(100, Math.max(0, score));
}

/**
 * 生成个性化健康建议
 */
function generatePersonalizedRecommendations(data) {
  const recommendations = [];
  const {
    healthProfile,
    bmiCategory,
    stepsAssessment,
    heartRateAssessment,
    sleepAssessment,
    bloodPressureAssessment,
    personalizedStandards
  } = data;

  // 孕期特殊建议
  if (healthProfile?.is_pregnant) {
    recommendations.push({
      category: '孕期健康',
      priority: 'high',
      advice: '您处于孕期，请遵循医生的运动建议。避免高强度运动，优先选择散步、游泳等温和运动。确保充足营养和水分摄入。'
    });
  }

  // 康复期特殊建议
  if (healthProfile?.is_recovering) {
    recommendations.push({
      category: '康复指导',
      priority: 'high',
      advice: '您正在康复期，请循序渐进地增加活动强度。建议在医生或物理治疗师的指导下进行。'
    });
  }

  // 心血管问题建议
  if (healthProfile?.has_cardiovascular_issues) {
    recommendations.push({
      category: '心血管健康',
      priority: 'high',
      advice: '您有心血管问题历史，建议定期检查心脏功能。避免突然的剧烈运动，选择温和有氧运动。监控血压和心率变化。'
    });
  }

  // 糖尿病管理建议
  if (healthProfile?.has_diabetes) {
    recommendations.push({
      category: '血糖管理',
      priority: 'high',
      advice: '您有糖尿病，建议定期监测血糖。保持规律运动（每周150分钟中等强度），控制饮食，特别是糖和精制碳水化合物摄入。'
    });
  }

  // 关节问题建议
  if (healthProfile?.has_joint_issues) {
    recommendations.push({
      category: '关节保护',
      priority: 'high',
      advice: '您有关节问题，建议选择低冲击运动如游泳、骑自行车、瑜伽。避免高冲击运动。考虑添加适度的力量训练来加强支持肌肉。'
    });
  }

  // BMI 建议
  if (bmiCategory) {
    if (bmiCategory.status === 'underweight') {
      recommendations.push({
        category: '体重管理',
        priority: 'medium',
        advice: `${bmiCategory.advice} 建议增加蛋白质和健康脂肪摄入，配合力量训练增肌。`
      });
    } else if (bmiCategory.status === 'overweight' || bmiCategory.status === 'obese') {
      recommendations.push({
        category: '体重管理',
        priority: bmiCategory.status === 'obese' ? 'high' : 'medium',
        advice: `${bmiCategory.advice} 建议每周运动至少${personalizedStandards?.activity_level === 'sedentary' ? 150 : 200}分钟。`
      });
    }
  }

  // 步数建议
  if (stepsAssessment) {
    if (stepsAssessment.priority === 'high') {
      recommendations.push({
        category: '运动建议',
        priority: 'high',
        advice: stepsAssessment.advice
      });
    } else if (stepsAssessment.priority === 'medium' && stepsAssessment.status !== 'optimal') {
      recommendations.push({
        category: '运动建议',
        priority: 'medium',
        advice: stepsAssessment.advice
      });
    }
  }

  // 睡眠建议
  if (sleepAssessment) {
    if (sleepAssessment.priority === 'high') {
      recommendations.push({
        category: '睡眠管理',
        priority: 'high',
        advice: sleepAssessment.advice
      });
    }
  }

  // 心率建议
  if (heartRateAssessment?.priority === 'high') {
    recommendations.push({
      category: '心血管健康',
      priority: 'high',
      advice: heartRateAssessment.advice
    });
  }

  // 血压建议
  if (bloodPressureAssessment?.priority === 'high') {
    recommendations.push({
      category: '血压管理',
      priority: 'high',
      advice: bloodPressureAssessment.advice
    });
  }

  // 如果没有特别建议，给予鼓励
  if (recommendations.length === 0) {
    recommendations.push({
      category: '综合评价',
      priority: 'low',
      advice: '您的各项健康指标都不错！继续保持健康的生活方式，定期检查。'
    });
  }

  return recommendations;
}

module.exports = {
  getPersonalizedHealthAnalysis,
  calculatePersonalizedHealthScore,
  generatePersonalizedRecommendations,
  getPersonalizedStepsAssessment,
  getPersonalizedHeartRateAssessment,
  getPersonalizedSleepAssessment,
  getPersonalizedBloodPressureAssessment,
  getPersonalizedBMICategory
};
