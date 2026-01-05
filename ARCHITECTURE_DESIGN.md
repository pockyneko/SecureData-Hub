# 个性化健康评估系统 - 架构设计文档

## 📐 系统架构概览

```
┌─────────────────────────────────────────────────────────────────┐
│                     前端层 (Flutter/Web)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  个性化健康档案编辑 → 健康分析展示 → 个性化建议           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓ HTTP/REST API
┌─────────────────────────────────────────────────────────────────┐
│                  后端API层 (Express.js)                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  /api/health-profile                                      │  │
│  │  - GET/POST/DELETE - 档案管理                            │  │
│  │  - /standards - 个性化标准                               │  │
│  │  - /analysis/personalized - 个性化分析                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓ SQL Queries
┌─────────────────────────────────────────────────────────────────┐
│                    数据层 (MySQL)                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  users                                                    │  │
│  │  ├── user_health_profiles (个性化档案)                    │  │
│  │  ├── health_standards_reference (标准参考)                │  │
│  │  ├── health_records (健康数据)                            │  │
│  │  ├── user_goals (用户目标)                                │  │
│  │  └── v_user_personalized_standards (个性化标准视图)        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 核心工作流

### 1. 用户档案创建流程

```
用户注册
  ↓
自动计算年龄组
  ↓
创建 user_health_profiles 记录
  ├─ age_group: 根据 birthday 计算
  ├─ activity_level: 默认 'moderately_active'
  ├─ health_condition: 默认 'good'
  └─ 其他特殊条件: 默认 false
  ↓
用户可编辑档案
  ├─ 修改运动水平
  ├─ 标记特殊条件
  └─ 添加医生建议
  ↓
档案保存完成
```

### 2. 个性化标准匹配流程

```
查询 user_health_profiles
  ↓
获取: age_group, gender, activity_level
  ↓
从 health_standards_reference 查询匹配的标准
  SELECT * FROM health_standards_reference
  WHERE age_group = ? 
    AND (gender = ? OR gender = 'all')
    AND activity_level = ?
  ↓
返回该组合的所有标准参数
  ├─ daily_steps_min/optimal/max
  ├─ resting_heart_rate_min/normal/max
  ├─ sleep_min/optimal/max
  ├─ blood_pressure_systolic/diastolic_normal
  ├─ bmi_optimal_min/max
  └─ water_intake_daily_ml
  ↓
如有 personalized_* 字段，则覆盖默认值
  ↓
标准应用完成
```

### 3. 健康分析流程

```
用户请求分析
  ↓
获取用户档案
  ├─ 查询 user_health_profiles
  ├─ 计算个性化标准
  └─ 获取特殊条件标记
  ↓
获取最新健康数据
  ├─ 最新体重
  ├─ 最新步数
  ├─ 最新心率
  ├─ 最新血压
  ├─ 最新睡眠
  └─ 其他指标
  ↓
执行多维度评估
  ├─ BMI评估 → getPersonalizedBMICategory()
  ├─ 步数评估 → getPersonalizedStepsAssessment()
  ├─ 心率评估 → getPersonalizedHeartRateAssessment()
  ├─ 睡眠评估 → getPersonalizedSleepAssessment()
  └─ 血压评估 → getPersonalizedBloodPressureAssessment()
  ↓
计算个性化健康评分
  ├─ 基础分: 60分
  ├─ BMI评分: +0-20
  ├─ 步数评分: +0-20
  ├─ 睡眠评分: +0-15
  ├─ 心率评分: +0-15
  ├─ 血压评分: +0-15
  └─ 特殊条件扣分: -5-10
  ↓
生成个性化建议
  ├─ 优先级排序: high → medium → low
  ├─ 基于评估结果
  ├─ 基于特殊条件
  └─ 可含医生建议
  ↓
返回完整分析报告
```

---

## 📦 核心数据结构

### user_health_profiles 表

```sql
CREATE TABLE user_health_profiles (
  id VARCHAR(36) PRIMARY KEY,          -- UUID
  user_id VARCHAR(36) UNIQUE,          -- 关联用户
  
  -- 基础特征
  age_group ENUM(...),                 -- 年龄段
  activity_level ENUM(...),            -- 运动水平
  health_condition ENUM(...),          -- 健康状况
  
  -- 特殊条件标记 (0/1)
  has_cardiovascular_issues,           -- 心血管问题
  has_diabetes,                        -- 糖尿病
  has_joint_issues,                    -- 关节问题
  is_pregnant,                         -- 孕期
  is_recovering,                       -- 康复期
  
  -- 个性化目标（可选覆盖默认值）
  personalized_steps_goal,             -- 个性化步数目标
  personalized_heart_rate_min,         -- 个性化心率最小值
  personalized_heart_rate_max,         -- 个性化心率最大值
  personalized_sleep_goal,             -- 个性化睡眠目标
  personalized_water_goal,             -- 个性化饮水目标
  
  -- 医疗信息
  doctor_notes TEXT,                   -- 医生建议
  
  created_at, updated_at               -- 时间戳
);
```

### health_standards_reference 表

```sql
CREATE TABLE health_standards_reference (
  id VARCHAR(36) PRIMARY KEY,
  
  -- 人群标签（唯一性约束）
  age_group ENUM(...),                 -- 年龄段
  gender ENUM('male', 'female', 'all'), -- 性别
  activity_level ENUM(...),            -- 运动水平
  
  -- 步数标准
  daily_steps_min,                     -- 最低
  daily_steps_optimal,                 -- 最优
  daily_steps_max,                     -- 最高
  
  -- 心率标准 (bpm)
  resting_heart_rate_min,              -- 静息心率最小
  resting_heart_rate_normal,           -- 静息心率正常上限
  max_heart_rate,                      -- 最大心率
  
  -- 睡眠标准 (小时)
  sleep_min, sleep_optimal, sleep_max,
  
  -- 血压标准 (mmHg)
  blood_pressure_systolic_normal,      -- 收缩压
  blood_pressure_diastolic_normal,     -- 舒张压
  
  -- BMI标准
  bmi_min, bmi_optimal_min, bmi_optimal_max, bmi_max,
  
  -- 饮水标准 (ml)
  water_intake_daily_ml,
  
  notes TEXT                           -- 说明文字
);
```

### 视图：v_user_personalized_standards

```sql
SELECT 
  u.id AS user_id,
  u.username,
  u.gender,
  YEAR(CURDATE()) - YEAR(u.birthday) AS age,
  hp.age_group,
  hp.activity_level,
  hp.health_condition,
  
  -- 合并个性化和默认标准
  COALESCE(hp.personalized_steps_goal, hsr.daily_steps_optimal) 
    AS recommended_daily_steps,
  COALESCE(hp.personalized_heart_rate_min, hsr.resting_heart_rate_min)
    AS recommended_heart_rate_min,
  -- ... 其他字段
  
  hp.doctor_notes,
  hp.updated_at
FROM users u
LEFT JOIN user_health_profiles hp ON u.id = hp.user_id
LEFT JOIN health_standards_reference hsr ON 
  hp.age_group = hsr.age_group AND 
  (hsr.gender = u.gender OR hsr.gender = 'all') AND
  hp.activity_level = hsr.activity_level
WHERE u.deleted_at IS NULL;
```

---

## 🔌 API 设计

### 资源建模

```
/api/health-profile
├─ 基本操作 (CRUD)
│  ├─ GET / - 获取档案
│  ├─ POST / - 创建/更新
│  ├─ DELETE / - 删除
│  └─ PUT /doctor-notes - 更新医生建议
├─ 标准查询
│  └─ GET /standards - 获取个性化标准
└─ 分析查询
   └─ GET /analysis/personalized - 个性化分析报告
```

### 请求/响应结构

#### 获取档案 - GET /

```json
// 请求
GET /api/health-profile
Authorization: Bearer <token>

// 响应 200
{
  "success": true,
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "age_group": "adult",
    "activity_level": "moderately_active",
    "health_condition": "good",
    "has_cardiovascular_issues": false,
    "has_diabetes": false,
    "has_joint_issues": false,
    "is_pregnant": false,
    "is_recovering": false,
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

#### 创建/更新档案 - POST /

```json
// 请求
POST /api/health-profile
Authorization: Bearer <token>
Content-Type: application/json

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
  "doctorNotes": null
}

// 响应 200
{
  "success": true,
  "message": "健康档案创建成功",
  "data": { ... }
}
```

#### 获取个性化标准 - GET /standards

```json
// 请求
GET /api/health-profile/standards
Authorization: Bearer <token>

// 响应 200
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "age_group": "adult",
    "activity_level": "moderately_active",
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

#### 获取个性化分析 - GET /analysis/personalized

```json
// 请求
GET /api/health-profile/analysis/personalized
Authorization: Bearer <token>

// 响应 200
{
  "success": true,
  "data": {
    "userInfo": { ... },
    "personalizationFactors": { ... },
    "currentStatus": { ... },
    "assessments": {
      "bmi": { ... },
      "steps": { ... },
      "heartRate": { ... },
      "sleep": { ... },
      "bloodPressure": { ... }
    },
    "healthScore": 82,
    "recommendations": [
      {
        "category": "运动建议",
        "priority": "medium",
        "advice": "..."
      }
    ],
    "personalizedStandards": { ... },
    "analyzedAt": "2026-01-05T10:15:00.000Z"
  }
}
```

---

## 🧮 评分算法

### 健康分数计算

```
基础分: 60

+ BMI评分 (最多20分)
  ├─ 正常 (18.5-24): +20
  ├─ 偏瘦/偏胖 (±5): +10
  └─ 肥胖: +0

+ 步数评分 (最多20分)
  ├─ 达到最优: +20
  ├─ 达到70%: +10
  ├─ 达到50%: +5
  └─ 低于50%: +0

+ 睡眠评分 (最多15分)
  ├─ 7-9小时: +15
  ├─ 6-10小时: +5
  └─ 其他: +0

+ 心率评分 (最多15分)
  ├─ 正常范围: +15
  ├─ 略高/略低: +5
  └─ 异常: +0

+ 血压评分 (最多15分)
  ├─ 正常: +15
  ├─ 略高: +5
  └─ 高血压: +0

- 特殊条件扣分
  ├─ 心血管问题: -10
  ├─ 糖尿病: -10
  ├─ 关节问题: -5
  ├─ 孕期: -5
  └─ 康复期: -5

最终分数 = 总分, 范围 [0, 100]
```

### 建议优先级

```
High (红色):
  - 血压异常
  - BMI严重超标
  - 步数严重不足
  - 睡眠不足
  - 特殊条件相关

Medium (橙色):
  - 步数接近目标但未达
  - 指标略微异常
  - 预防性建议

Low (绿色):
  - 指标正常，维持建议
  - 优化建议
  - 鼓励信息
```

---

## 🔐 安全性考虑

### 认证
```
所有 /api/health-profile 接口都需要:
- Authorization: Bearer <jwt_token>
- Token 通过 /api/auth/login 获得
```

### 授权
```
用户只能访问自己的档案和数据:
- 获取档案: 检查 user_id == 当前用户
- 更新档案: 检查 user_id == 当前用户
- 删除档案: 检查 user_id == 当前用户
```

### 数据验证
```
POST /api/health-profile 的验证规则:
- ageGroup: 必须在枚举值中
- activityLevel: 必须在枚举值中
- healthCondition: 必须在枚举值中
- 布尔字段: 正确的类型检查
- 数字字段: 范围检查
```

---

## 🏃 性能优化

### 数据库优化
```sql
-- 添加索引
CREATE INDEX idx_user_health_profiles_user_id 
  ON user_health_profiles(user_id);

CREATE INDEX idx_health_standards_ref 
  ON health_standards_reference(age_group, gender, activity_level);

-- 视图已优化，使用 LEFT JOIN
```

### 查询优化
```javascript
// 合并查询，减少数据库往返
const [profile, standards, records] = await Promise.all([
  getHealthProfile(userId),
  getPersonalizedStandards(userId),
  getLatestHealthRecords(userId)
]);
```

### 缓存策略
```
- 个性化标准: 缓存1小时（用户档案不常改变）
- 健康分析: 缓存30分钟（数据更新不频繁）
- 健康记录: 缓存不超过5分钟（需要实时性）
```

---

## 📊 可扩展性

### 添加新的人群标准

```sql
-- 示例：添加儿童标准
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level,
  daily_steps_min, daily_steps_optimal, daily_steps_max,
  -- ... 其他字段
) VALUES (
  UUID(), 'child', 'all', 'moderately_active',
  5000, 8000, 12000,
  -- ... 其他值
);
```

### 添加新的特殊条件

```sql
-- 修改 user_health_profiles 表
ALTER TABLE user_health_profiles ADD COLUMN 
  has_hypertension TINYINT(1) DEFAULT 0 COMMENT '高血压';

-- 在分析中处理
if (profile.has_hypertension) {
  // 特殊建议
}
```

### 添加新的评分指标

```javascript
// 修改 calculatePersonalizedHealthScore()
// 添加新指标评分逻辑
if (metabolicRate) {
  if (metabolicRate >= 1.0) score += 10;
}
```

---

## 🧪 测试策略

### 单元测试
```
- calculatePersonalizedHealthScore()
- getPersonalizedBMICategory()
- 各个评估函数
- 年龄组计算
```

### 集成测试
```
- 完整的 API 请求流程
- 数据库操作
- 视图查询
```

### 场景测试
```
- 久坐上班族场景
- 中年人场景
- 老年人场景
- 孕期女性场景
- 康复期患者场景
- 特殊疾病场景
```

---

## 📋 部署清单

- [ ] 数据库迁移脚本执行
- [ ] 表结构验证
- [ ] 视图创建验证
- [ ] 标准数据插入验证
- [ ] API 端点测试
- [ ] 前端集成测试
- [ ] 性能基准测试
- [ ] 安全审计
- [ ] 文档完善
- [ ] 用户培训

---

## 📚 相关文档

- `PERSONALIZED_HEALTH_API.md` - API 详细文档
- `DEPLOYMENT_GUIDE.md` - 部署指南
- `FRONTEND_INTEGRATION_GUIDE.md` - 前端集成
- `IMPLEMENTATION_SUMMARY.md` - 实现总结

---

**版本**: 1.0
**最后更新**: 2026-01-05
**维护者**: HealthTrack 团队
