# 个性化健康评估系统 - API 文档

## 概述

本系统实现了**基于个人特征的个性化健康评估系统**，摒弃了"10000步通用标准"的做法，转而根据用户的：
- 年龄段（儿童、青少年、成人、中年、老年）
- 性别（男性、女性）
- 运动水平（久坐、轻度、中等、活跃、非常活跃）
- 特殊健康条件（心血管问题、糖尿病、关节问题、孕期等）

为每个用户定制专属的健康标准和评估。

---

## 核心功能

### 1. **个性化健康档案管理**
用户可以建立详细的健康档案，系统会基于这些信息自动生成个性化的健康标准。

### 2. **个性化健康分析报告**
系统不再使用固定的健康标准（如所有人都是10000步），而是根据用户档案动态调整：
- ✅ 久坐上班族：5000-7000步就很健康
- ✅ 中年人：6000-8000步的目标更合理
- ✅ 老年人：4000-7000步已经足够
- ✅ 运动爱好者：12000-20000步是目标
- ✅ 孕期妇女：轻度散步4000-6000步即可

### 3. **多维度健康评估**
- BMI评估（个性化范围）
- 步数评估（个性化目标）
- 心率评估（个性化范围）
- 睡眠评估（个性化建议）
- 血压评估（个性化标准）

### 4. **医疗专业建议支持**
医生或医疗专业人士可以为患者添加特殊建议和注意事项。

---

## API 端点

### 基础路径：`/api/health-profile`

所有接口均需认证（Bearer Token）

---

## 1. 健康档案管理

### 1.1 获取用户健康档案
```
GET /api/health-profile
```

**请求头：**
```
Authorization: Bearer <access_token>
```

**成功响应 (200)：**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "age_group": "adult",
    "activity_level": "moderately_active",
    "health_condition": "good",
    "has_cardiovascular_issues": 0,
    "has_diabetes": 0,
    "has_joint_issues": 0,
    "is_pregnant": 0,
    "is_recovering": 0,
    "personalized_steps_goal": null,
    "personalized_heart_rate_min": null,
    "personalized_heart_rate_max": null,
    "personalized_sleep_goal": null,
    "personalized_water_goal": null,
    "doctor_notes": null,
    "created_at": "2026-01-05T10:00:00.000Z",
    "updated_at": "2026-01-05T10:00:00.000Z"
  }
}
```

---

### 1.2 创建或更新健康档案
```
POST /api/health-profile
```

**请求体：**
```json
{
  "ageGroup": "adult",
  "activityLevel": "moderately_active",
  "healthCondition": "good",
  "hasCardiovascularIssues": false,
  "hasDiabetes": false,
  "hasJointIssues": false,
  "isPregnant": false,
  "isRecovering": false,
  "personalizedStepsGoal": null,
  "personalizedHeartRateMin": null,
  "personalizedHeartRateMax": null,
  "personalizedSleepGoal": null,
  "personalizedWaterGoal": null,
  "doctorNotes": "无特殊注意事项"
}
```

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ageGroup | string | 是 | 年龄段：child(0-12), teen(13-18), adult(19-40), middle_age(41-65), senior(65+) |
| activityLevel | string | 否 | 运动水平：sedentary(久坐), lightly_active(轻度), moderately_active(中等), very_active(活跃), extremely_active(非常活跃) |
| healthCondition | string | 否 | 健康状况：excellent, good, fair, poor |
| hasCardiovascularIssues | boolean | 否 | 是否有心血管问题 |
| hasDiabetes | boolean | 否 | 是否有糖尿病 |
| hasJointIssues | boolean | 否 | 是否有关节问题 |
| isPregnant | boolean | 否 | 是否孕期 |
| isRecovering | boolean | 否 | 是否康复期 |
| personalizedStepsGoal | number | 否 | 个性化每日步数目标（0-50000） |
| personalizedHeartRateMin | number | 否 | 个性化心率最小值（0-200 bpm） |
| personalizedHeartRateMax | number | 否 | 个性化心率最大值（0-220 bpm） |
| personalizedSleepGoal | number | 否 | 个性化睡眠目标（0-15小时） |
| personalizedWaterGoal | number | 否 | 个性化饮水目标（ml） |
| doctorNotes | string | 否 | 医生建议或特殊注意事项 |

**成功响应 (200)：**
```json
{
  "success": true,
  "message": "健康档案创建成功",
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    ...
  }
}
```

---

### 1.3 删除健康档案
```
DELETE /api/health-profile
```

**成功响应 (200)：**
```json
{
  "success": true,
  "message": "健康档案删除成功"
}
```

---

### 1.4 更新医生建议
```
PUT /api/health-profile/doctor-notes
```

**请求体：**
```json
{
  "doctorNotes": "患者有高血压倾向，建议每天运动30分钟，避免高盐食物"
}
```

**成功响应 (200)：**
```json
{
  "success": true,
  "message": "医生建议更新成功",
  "data": {
    ...
  }
}
```

---

## 2. 个性化标准管理

### 2.1 获取个性化健康标准
```
GET /api/health-profile/standards
```

**成功响应 (200)：**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "username": "zhangsan",
    "gender": "male",
    "age": 35,
    "age_group": "adult",
    "activity_level": "moderately_active",
    "health_condition": "good",
    "recommended_daily_steps": 10000,
    "recommended_heart_rate_min": 60,
    "recommended_heart_rate_max": 80,
    "recommended_sleep_hours": 8,
    "recommended_water_ml": 2500,
    "bmi_optimal_range": "18.5-24",
    "blood_pressure_normal": "120/80 mmHg",
    "doctor_notes": null,
    "updated_at": "2026-01-05T10:00:00.000Z"
  }
}
```

**数据说明：**

这个接口返回的是根据用户的健康档案自动匹配的个性化标准。系统会从 `health_standards_reference` 表中查找最适配的标准。

例如：
- 若用户是35岁男性，中等运动量 → 推荐10000步，8小时睡眠
- 若用户是65岁老年人，轻度运动 → 推荐7000步，8小时睡眠，血压标准调宽至130/85
- 若用户孕期，运动量轻 → 推荐6000步，9小时睡眠，3000ml饮水

---

## 3. 个性化健康分析

### 3.1 获取个性化健康分析报告
```
GET /api/health-profile/analysis/personalized
```

**成功响应 (200)：**
```json
{
  "success": true,
  "data": {
    "userInfo": {
      "id": "uuid",
      "nickname": "张三",
      "height": 175,
      "gender": "male",
      "ageGroup": "adult",
      "activityLevel": "moderately_active",
      "healthCondition": "good"
    },
    "personalizationFactors": {
      "hasCardiovascularIssues": false,
      "hasDiabetes": false,
      "hasJointIssues": false,
      "isPregnant": false,
      "isRecovering": false,
      "doctorNotes": null
    },
    "currentStatus": {
      "weight": 70,
      "steps": 8500,
      "heartRate": 72,
      "bloodPressure": "118/75",
      "sleep": 7.5
    },
    "assessments": {
      "bmi": {
        "label": "正常",
        "status": "normal",
        "bmi": 22.9,
        "min": 18.5,
        "max": 24,
        "advice": "您的BMI为22.9，处于健康范围18.5-24。继续保持！"
      },
      "steps": {
        "current": 8500,
        "min": 7000,
        "optimal": 10000,
        "max": 15000,
        "userGoal": 10000,
        "status": "below_optimal",
        "percentage": "85.0",
        "advice": "您的步数为8500，距离最优10000步还差1500步。继续加油！",
        "priority": "medium"
      },
      "heartRate": {
        "current": 72,
        "min": 55,
        "normal": 75,
        "max": 190,
        "status": "normal",
        "advice": "您的静息心率为72bpm，处于健康范围。",
        "priority": "low"
      },
      "sleep": {
        "current": 7.5,
        "min": 7,
        "optimal": 8,
        "max": 9,
        "status": "optimal",
        "advice": "您的睡眠时间为7.5小时，在健康范围内。继续保持良好作息。",
        "priority": "low"
      },
      "bloodPressure": {
        "current": "118/75",
        "normalSys": 120,
        "normalDia": 80,
        "status": "optimal",
        "advice": "您的血压为118/75mmHg，处于正常范围。很好！",
        "priority": "low"
      }
    },
    "healthScore": 88,
    "recommendations": [
      {
        "category": "运动建议",
        "priority": "medium",
        "advice": "您的步数为8500，距离最优10000步还差1500步。继续加油！"
      }
    ],
    "personalizedStandards": {
      "recommendedDailySteps": 10000,
      "recommendedHeartRateRange": "60-80 bpm",
      "recommendedSleepHours": 8,
      "recommendedWaterMl": 2500,
      "bmiOptimalRange": "18.5-24",
      "bloodPressureNormal": "120/80 mmHg"
    },
    "analyzedAt": "2026-01-05T10:15:00.000Z"
  }
}
```

**关键字段说明：**

- **healthScore**: 个性化综合健康评分（0-100），根据所有指标加权计算
- **assessments**: 各项指标的详细评估，包括：
  - `status`: 当前状态（优、良、中、差等）
  - `advice`: 针对该项的个性化建议
  - `priority`: 优先级（high、medium、low）
- **recommendations**: 基于所有评估生成的优先级排序建议列表

---

## 年龄段和运动水平的组合示例

### 成人 (19-40岁)

**久坐运动量 (sedentary):**
- 每日步数：3000-7000，目标5000
- 心率范围：60-80 bpm
- 睡眠：7-9小时，目标8小时
- 血压：<120/80 mmHg

**中等运动量 (moderately_active):**
- 每日步数：7000-15000，目标10000
- 心率范围：55-75 bpm
- 睡眠：7-9小时，目标8小时
- 血压：<120/80 mmHg

**高运动量 (very_active):**
- 每日步数：12000-20000，目标15000
- 心率范围：50-70 bpm
- 睡眠：7-9小时，目标8小时
- 血压：<120/80 mmHg

### 中年人 (41-65岁)

**中等运动量 (moderately_active):**
- 每日步数：6000-12000，目标8000
- 心率范围：60-80 bpm
- 睡眠：7-9小时，目标8小时
- 血压：<120/80 mmHg（需定期监测）

### 老年人 (65岁+)

**中等运动量 (moderately_active):**
- 每日步数：4000-10000，目标7000
- 心率范围：60-85 bpm
- 睡眠：7-9小时，目标8小时
- 血压：<130/85 mmHg（允许略高以保证脑供血）
- 重点：预防跌倒，保持肌肉力量

### 孕期女性 (任何年龄)

**轻度运动量 (lightly_active):**
- 每日步数：4000-8000，目标6000
- 心率范围：60-90 bpm（心率会自然升高）
- 睡眠：8-10小时，目标9小时
- 饮水：3000ml+（特别增加）
- 血压：<120/80 mmHg（需定期监测）
- 重点：避免高强度运动，优先散步

---

## 健康标准参考表详解

系统内置了一个 `health_standards_reference` 表，包含以下人群的标准：

| 年龄段 | 性别 | 运动水平 | 步数目标 | 心率范围 | 睡眠 | 血压 | BMI范围 |
|--------|------|---------|----------|----------|------|------|---------|
| 成人 | 女 | 久坐 | 5000 | 60-80 | 7-9 | <120/80 | 18.5-24 |
| 成人 | 男 | 久坐 | 6000 | 60-80 | 7-9 | <120/80 | 18.5-24 |
| 成人 | 全部 | 中等 | 10000 | 55-75 | 7-9 | <120/80 | 18.5-24 |
| 成人 | 全部 | 活跃 | 15000 | 50-70 | 7-9 | <120/80 | 18.5-24 |
| 中年 | 全部 | 中等 | 8000 | 60-80 | 7-9 | <120/80 | 18.5-24 |
| 老年 | 全部 | 中等 | 7000 | 60-85 | 7-9 | <130/85 | 18.5-27 |
| 孕期 | 女 | 轻度 | 6000 | 60-90 | 8-10 | <120/80 | 18.5-30 |

---

## 特殊条件处理

### 心血管问题患者
- 避免突然的剧烈运动
- 重点监测心率和血压
- 建议温和的有氧运动

### 糖尿病患者
- 定期监测血糖
- 保持规律运动
- 控制饮食（特别是糖类）

### 关节问题患者
- 选择低冲击运动（游泳、骑自行车、瑜伽）
- 避免高冲击运动（跑步、跳跃）
- 加强支持肌肉训练

### 康复期患者
- 循序渐进增加活动强度
- 在医疗专业人士指导下进行
- 定期评估进度

---

## 错误响应示例

**400 - 请求参数错误：**
```json
{
  "success": false,
  "errors": [
    {
      "msg": "ageGroup is invalid",
      "param": "ageGroup"
    }
  ]
}
```

**401 - 未认证：**
```json
{
  "success": false,
  "message": "需要身份验证",
  "code": "UNAUTHORIZED"
}
```

**500 - 服务器错误：**
```json
{
  "success": false,
  "message": "获取个性化健康分析失败",
  "error": "error message"
}
```

---

## 使用流程示例

### 步骤1：用户注册或登录
```bash
POST /api/auth/register
或
POST /api/auth/login
```

### 步骤2：创建个性化健康档案
```bash
POST /api/health-profile
Content-Type: application/json
Authorization: Bearer <token>

{
  "ageGroup": "adult",
  "activityLevel": "sedentary",
  "healthCondition": "good"
}
```

### 步骤3：查看个性化标准
```bash
GET /api/health-profile/standards
Authorization: Bearer <token>
```

### 步骤4：上传健康数据
```bash
POST /api/health/records
Authorization: Bearer <token>

{
  "type": "steps",
  "value": 8500,
  "recordDate": "2026-01-05"
}
```

### 步骤5：获取个性化分析报告
```bash
GET /api/health-profile/analysis/personalized
Authorization: Bearer <token>
```

---

## 前端集成建议

### React/Vue 示例
```javascript
// 获取个性化分析报告
async function getPersonalizedAnalysis(token) {
  const response = await fetch('/api/health-profile/analysis/personalized', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  const data = await response.json();
  return data;
}

// 显示个性化建议
function renderRecommendations(analysis) {
  const recommendations = analysis.data.recommendations
    .sort((a, b) => {
      const priority = { high: 0, medium: 1, low: 2 };
      return priority[a.priority] - priority[b.priority];
    });
  
  recommendations.forEach(rec => {
    console.log(`[${rec.priority}] ${rec.category}: ${rec.advice}`);
  });
}
```

---

## 总结

这个个性化健康评估系统的核心优势：

✅ **摒弃一刀切标准** - 不再说"所有人都应该走10000步"
✅ **科学分级** - 基于年龄、性别、运动水平的科学划分
✅ **医疗友好** - 支持特殊条件标记和医生建议
✅ **动态调整** - 用户可自定义个性化目标
✅ **详细反馈** - 每项指标都有优先级和针对性建议

通过使用本系统，用户能获得真正属于自己的健康评估和建议！
