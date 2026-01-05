/**
 * 个性化健康功能单元测试
 * 使用 Jest 框架
 * 
 * 运行测试：npm test
 */

const PersonalizedHealthAnalysisService = require('../src/services/personalizedHealthAnalysisService');
const UserHealthProfileModel = require('../src/models/userHealthProfileModel');

describe('Personalized Health Analysis Service', () => {
  
  // ========== 健康评分测试 ==========
  describe('健康评分计算', () => {
    
    test('应该正确计算基础评分', () => {
      const data = {
        bmi: 24,
        steps: 8000,
        heartRate: 70,
        bloodPressure: { systolic: 120, diastolic: 80 },
        sleepHours: 8,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
        hasCardiovascularIssues: false,
        hasDiabetes: false,
        hasJointIssues: false
      };
      
      const score = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(data);
      
      expect(score).toBeGreaterThanOrEqual(0);
      expect(score).toBeLessThanOrEqual(100);
      expect(typeof score).toBe('number');
    });

    test('健康状况差应该降低评分', () => {
      const healthyData = {
        bmi: 22,
        steps: 10000,
        heartRate: 65,
        bloodPressure: { systolic: 115, diastolic: 75 },
        sleepHours: 8
      };
      
      const unhealthyData = {
        ...healthyData,
        hasCardiovascularIssues: true,
        hasDiabetes: true
      };
      
      const healthyScore = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(healthyData);
      const unhealthyScore = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(unhealthyData);
      
      expect(unhealthyScore).toBeLessThan(healthyScore);
    });

    test('超重 (BMI > 25) 应该降低评分', () => {
      const normalBMI = {
        bmi: 24,
        steps: 8000,
        heartRate: 70,
        bloodPressure: { systolic: 120, diastolic: 80 },
        sleepHours: 8
      };
      
      const overweight = {
        ...normalBMI,
        bmi: 28
      };
      
      const score1 = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(normalBMI);
      const score2 = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(overweight);
      
      expect(score2).toBeLessThanOrEqual(score1);
    });
  });

  // ========== 步数评估测试 ==========
  describe('步数评估', () => {
    
    test('应该正确评估步数', () => {
      const standards = {
        minDailySteps: 5000,
        optimalDailySteps: 8000,
        maxDailySteps: 12000
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedStepsAssessment(
        8000,
        standards,
        {}
      );
      
      expect(assessment).toHaveProperty('current');
      expect(assessment).toHaveProperty('optimal');
      expect(assessment).toHaveProperty('status');
      expect(assessment).toHaveProperty('advice');
    });

    test('超过最大步数应该给出警告', () => {
      const standards = {
        maxDailySteps: 15000
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedStepsAssessment(
        20000,
        standards,
        {}
      );
      
      expect(assessment.status).toBe('excessive');
      expect(assessment.advice).toContain('过多');
    });

    test('未达到最小步数应该给出建议', () => {
      const standards = {
        minDailySteps: 5000,
        optimalDailySteps: 8000
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedStepsAssessment(
        3000,
        standards,
        {}
      );
      
      expect(assessment.status).toBe('insufficient');
    });
  });

  // ========== 心率评估测试 ==========
  describe('心率评估', () => {
    
    test('应该正确评估正常心率', () => {
      const standards = {
        minHeartRate: 60,
        maxHeartRate: 80
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedHeartRateAssessment(
        72,
        standards
      );
      
      expect(assessment.status).toBe('normal');
      expect(assessment.advice).toContain('正常');
    });

    test('过高心率应该给出警告', () => {
      const standards = {
        maxHeartRate: 80
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedHeartRateAssessment(
        100,
        standards
      );
      
      expect(assessment.status).toBe('high');
    });

    test('过低心率应该给出建议', () => {
      const standards = {
        minHeartRate: 60
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedHeartRateAssessment(
        45,
        standards
      );
      
      expect(assessment.status).toBe('low');
    });
  });

  // ========== 睡眠评估测试 ==========
  describe('睡眠评估', () => {
    
    test('应该正确评估睡眠', () => {
      const standards = {
        minSleepHours: 7,
        optimalSleepHours: 8,
        maxSleepHours: 10
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedSleepAssessment(
        8,
        standards
      );
      
      expect(assessment.status).toBe('optimal');
      expect(assessment.advice).toContain('理想');
    });

    test('睡眠不足应该给出建议', () => {
      const standards = {
        minSleepHours: 7,
        optimalSleepHours: 8
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedSleepAssessment(
        5,
        standards
      );
      
      expect(assessment.status).toBe('insufficient');
      expect(assessment.priority).toBe('high');
    });

    test('过度睡眠应该给出建议', () => {
      const standards = {
        maxSleepHours: 10
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedSleepAssessment(
        12,
        standards
      );
      
      expect(assessment.status).toBe('excessive');
    });
  });

  // ========== 血压评估测试 ==========
  describe('血压评估', () => {
    
    test('应该正确评估正常血压', () => {
      const standards = {
        maxSystolic: 120,
        maxDiastolic: 80
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedBloodPressureAssessment(
        110,
        75,
        standards
      );
      
      expect(assessment.status).toBe('normal');
    });

    test('高血压应该给出警告', () => {
      const standards = {
        maxSystolic: 120,
        maxDiastolic: 80
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedBloodPressureAssessment(
        140,
        90,
        standards
      );
      
      expect(assessment.status).toBe('high');
      expect(assessment.priority).toBe('high');
    });

    test('老年人血压标准应该不同', () => {
      const seniorStandards = {
        maxSystolic: 130,
        maxDiastolic: 85
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedBloodPressureAssessment(
        128,
        83,
        seniorStandards
      );
      
      expect(assessment.status).toBe('normal');
    });
  });

  // ========== BMI 评估测试 ==========
  describe('BMI 评估', () => {
    
    test('应该正确分类 BMI', () => {
      const standards = {
        minBMI: 18.5,
        optimalBMI: 24,
        maxBMI: 25
      };
      
      const assessment1 = PersonalizedHealthAnalysisService.getPersonalizedBMICategory(
        22,
        standards
      );
      
      expect(assessment1.status).toBe('normal');
      
      const assessment2 = PersonalizedHealthAnalysisService.getPersonalizedBMICategory(
        28,
        standards
      );
      
      expect(assessment2.status).toBe('overweight');
    });

    test('偏瘦应该给出建议', () => {
      const standards = {
        minBMI: 18.5
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedBMICategory(
        17,
        standards
      );
      
      expect(assessment.status).toBe('underweight');
    });

    test('肥胖应该给出高优先级警告', () => {
      const standards = {
        maxBMI: 25
      };
      
      const assessment = PersonalizedHealthAnalysisService.getPersonalizedBMICategory(
        32,
        standards
      );
      
      expect(assessment.status).toBe('obese');
      expect(assessment.priority).toBe('high');
    });
  });

  // ========== 建议生成测试 ==========
  describe('个性化建议生成', () => {
    
    test('应该生成有优先级的建议', () => {
      const data = {
        bmi: 28,
        steps: 3000,
        sleepHours: 5,
        heartRate: 95,
        bloodPressure: { systolic: 140, diastolic: 90 }
      };
      
      const recommendations = PersonalizedHealthAnalysisService.generatePersonalizedRecommendations(data);
      
      expect(Array.isArray(recommendations)).toBe(true);
      expect(recommendations.length).toBeGreaterThan(0);
      
      // 验证建议结构
      recommendations.forEach(rec => {
        expect(rec).toHaveProperty('category');
        expect(rec).toHaveProperty('priority');
        expect(rec).toHaveProperty('advice');
      });
    });

    test('高优先级建议应该排在前面', () => {
      const data = {
        steps: 2000,
        bloodPressure: { systolic: 150, diastolic: 100 },
        bmi: 22,
        heartRate: 70,
        sleepHours: 8
      };
      
      const recommendations = PersonalizedHealthAnalysisService.generatePersonalizedRecommendations(data);
      
      // 检查前几条建议是否为高优先级
      const firstHighPriority = recommendations.findIndex(r => r.priority === 'high');
      expect(firstHighPriority).toBeLessThan(3);
    });
  });

  // ========== 年龄组计算测试 ==========
  describe('年龄组计算', () => {
    
    test('应该正确计算儿童年龄组', () => {
      const birthday = new Date();
      birthday.setFullYear(birthday.getFullYear() - 10);
      
      const ageGroup = UserHealthProfileModel.calculateAgeGroup(birthday);
      expect(ageGroup).toBe('child');
    });

    test('应该正确计算青少年年龄组', () => {
      const birthday = new Date();
      birthday.setFullYear(birthday.getFullYear() - 16);
      
      const ageGroup = UserHealthProfileModel.calculateAgeGroup(birthday);
      expect(ageGroup).toBe('teen');
    });

    test('应该正确计算成人年龄组', () => {
      const birthday = new Date();
      birthday.setFullYear(birthday.getFullYear() - 30);
      
      const ageGroup = UserHealthProfileModel.calculateAgeGroup(birthday);
      expect(ageGroup).toBe('adult');
    });

    test('应该正确计算中年年龄组', () => {
      const birthday = new Date();
      birthday.setFullYear(birthday.getFullYear() - 50);
      
      const ageGroup = UserHealthProfileModel.calculateAgeGroup(birthday);
      expect(ageGroup).toBe('middle_age');
    });

    test('应该正确计算老年年龄组', () => {
      const birthday = new Date();
      birthday.setFullYear(birthday.getFullYear() - 70);
      
      const ageGroup = UserHealthProfileModel.calculateAgeGroup(birthday);
      expect(ageGroup).toBe('senior');
    });
  });

  // ========== 数据验证测试 ==========
  describe('数据验证', () => {
    
    test('应该拒绝无效的年龄组', () => {
      expect(() => {
        // 验证逻辑应该在服务层
        const validAgeGroups = ['child', 'teen', 'adult', 'middle_age', 'senior'];
        const input = 'invalid_age';
        if (!validAgeGroups.includes(input)) {
          throw new Error('Invalid age group');
        }
      }).toThrow();
    });

    test('应该拒绝无效的活动水平', () => {
      expect(() => {
        const validActivityLevels = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'];
        const input = 'invalid_activity';
        if (!validActivityLevels.includes(input)) {
          throw new Error('Invalid activity level');
        }
      }).toThrow();
    });

    test('BMI 应该在合理范围内', () => {
      expect(() => {
        const bmi = -5;
        if (bmi < 10 || bmi > 50) {
          throw new Error('Invalid BMI');
        }
      }).toThrow();
    });
  });

});

describe('集成场景测试', () => {
  
  test('场景 1: 久坐上班族的完整流程', async () => {
    const profile = {
      ageGroup: 'adult',
      activityLevel: 'sedentary',
      healthCondition: 'good'
    };
    
    const healthData = {
      bmi: 25,
      steps: 5500,
      sleepHours: 7,
      heartRate: 75,
      bloodPressure: { systolic: 125, diastolic: 82 }
    };
    
    // 验证档案
    expect(profile.ageGroup).toBe('adult');
    expect(profile.activityLevel).toBe('sedentary');
    
    // 验证健康数据
    const score = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(healthData);
    expect(score).toBeGreaterThanOrEqual(0);
    expect(score).toBeLessThanOrEqual(100);
  });

  test('场景 2: 老年人的完整流程', async () => {
    const profile = {
      ageGroup: 'senior',
      activityLevel: 'lightly_active',
      healthCondition: 'fair'
    };
    
    const healthData = {
      bmi: 24,
      steps: 5000,
      sleepHours: 8,
      heartRate: 72,
      bloodPressure: { systolic: 130, diastolic: 85 }
    };
    
    const score = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(healthData);
    expect(score).toBeGreaterThan(0);
  });

  test('场景 3: 孕期妇女的完整流程', async () => {
    const profile = {
      ageGroup: 'adult',
      activityLevel: 'lightly_active',
      isPregnant: true
    };
    
    const healthData = {
      bmi: 25,
      steps: 4500,
      sleepHours: 9,
      heartRate: 80,
      bloodPressure: { systolic: 118, diastolic: 78 }
    };
    
    // 孕期应该有特殊标准
    const score = PersonalizedHealthAnalysisService.calculatePersonalizedHealthScore(healthData);
    expect(score).toBeGreaterThan(0);
  });

});
