# 个性化健康评估系统 - 部署指南

## 📋 概述

本指南说明如何在现有的 HealthTrack 系统中部署个性化健康评估功能。

---

## 🔧 部署步骤

### 第1步：数据库迁移

运行新增的SQL迁移脚本：

```bash
# 连接到 MySQL 数据库
mysql -u root -p healthtrack < sql/04_personalized_health_standards.sql
```

**脚本会创建：**
1. `user_health_profiles` - 用户个性化健康档案表
2. `health_standards_reference` - 健康标准参考表
3. `v_user_personalized_standards` - 视图（用于快速查询个性化标准）

**修改：**
- 为 `user_goals` 表添加 `reason_for_change` 和 `is_personalized` 字段

---

### 第2步：后端代码部署

新增以下文件已自动创建：

```
src/
├── models/
│   └── userHealthProfileModel.js          # 新增
├── services/
│   └── personalizedHealthAnalysisService.js  # 新增
└── routes/
    └── personalizedHealthRoutes.js         # 新增
```

**修改的文件：**
- `src/models/index.js` - 添加导出 `UserHealthProfileModel`
- `src/services/index.js` - 添加导出个性化健康分析服务
- `src/routes/index.js` - 添加导出个性化路由
- `src/app.js` - 集成个性化健康路由

---

### 第3步：验证部署

#### 测试数据库连接
```bash
mysql -u root -p healthtrack -e "SELECT COUNT(*) FROM health_standards_reference;"
```

应该返回 7 行预插入的标准数据。

#### 测试API接口
```bash
# 1. 获取健康档案（需要有效的token）
curl -X GET http://localhost:3000/api/health-profile \
  -H "Authorization: Bearer <your_token>"

# 2. 创建健康档案
curl -X POST http://localhost:3000/api/health-profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_token>" \
  -d '{
    "ageGroup": "adult",
    "activityLevel": "moderately_active",
    "healthCondition": "good"
  }'

# 3. 获取个性化分析
curl -X GET http://localhost:3000/api/health-profile/analysis/personalized \
  -H "Authorization: Bearer <your_token>"
```

---

## 📖 API 快速参考

### 个性化健康档案相关

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/api/health-profile` | 获取用户健康档案 |
| POST | `/api/health-profile` | 创建/更新健康档案 |
| DELETE | `/api/health-profile` | 删除健康档案 |
| GET | `/api/health-profile/standards` | 获取个性化标准 |
| GET | `/api/health-profile/analysis/personalized` | 获取个性化分析报告 |
| PUT | `/api/health-profile/doctor-notes` | 更新医生建议 |

### 数据库表结构

#### user_health_profiles 表
```sql
CREATE TABLE user_health_profiles (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) UNIQUE,
  age_group ENUM('child', 'teen', 'adult', 'middle_age', 'senior'),
  activity_level ENUM('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'),
  health_condition ENUM('excellent', 'good', 'fair', 'poor'),
  has_cardiovascular_issues TINYINT(1),
  has_diabetes TINYINT(1),
  has_joint_issues TINYINT(1),
  is_pregnant TINYINT(1),
  is_recovering TINYINT(1),
  personalized_steps_goal INT,
  personalized_heart_rate_min INT,
  personalized_heart_rate_max INT,
  personalized_sleep_goal DECIMAL(4,2),
  personalized_water_goal INT,
  doctor_notes TEXT,
  created_at DATETIME,
  updated_at DATETIME
);
```

#### health_standards_reference 表
```sql
CREATE TABLE health_standards_reference (
  id VARCHAR(36) PRIMARY KEY,
  age_group ENUM('child', 'teen', 'adult', 'middle_age', 'senior'),
  gender ENUM('male', 'female', 'all'),
  activity_level ENUM('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'),
  daily_steps_min INT,
  daily_steps_optimal INT,
  daily_steps_max INT,
  resting_heart_rate_min INT,
  resting_heart_rate_normal INT,
  max_heart_rate INT,
  sleep_min DECIMAL(4,2),
  sleep_optimal DECIMAL(4,2),
  sleep_max DECIMAL(4,2),
  blood_pressure_systolic_normal INT,
  blood_pressure_diastolic_normal INT,
  bmi_min DECIMAL(5,2),
  bmi_optimal_min DECIMAL(5,2),
  bmi_optimal_max DECIMAL(5,2),
  bmi_max DECIMAL(5,2),
  water_intake_daily_ml INT,
  notes TEXT,
  created_at DATETIME
);
```

---

## 🎯 使用场景示例

### 场景1：久坐上班族
```json
{
  "ageGroup": "adult",
  "activityLevel": "sedentary",
  "healthCondition": "good"
}
```
**自动分配标准：**
- 每日步数目标：5000-7000
- 推荐运动：从轻度开始，逐步增加
- 重点关注：久坐导致的肌肉萎缩

### 场景2：中年管理者
```json
{
  "ageGroup": "middle_age",
  "activityLevel": "lightly_active",
  "healthCondition": "fair",
  "hasCardiovascularIssues": true
}
```
**自动分配标准：**
- 每日步数目标：6000-8000
- 心率监测：更严格的范围
- 重点关注：血压和心率变化
- 建议：定期体检

### 场景3：孕期妇女
```json
{
  "ageGroup": "adult",
  "activityLevel": "lightly_active",
  "healthCondition": "good",
  "isPregnant": true
}
```
**自动分配标准：**
- 每日步数目标：4000-6000（轻度散步）
- 睡眠：8-10小时
- 饮水：3000ml+
- 重点关注：避免高强度运动

### 场景4：老年康复者
```json
{
  "ageGroup": "senior",
  "activityLevel": "lightly_active",
  "healthCondition": "fair",
  "isRecovering": true,
  "has_joint_issues": true
}
```
**自动分配标准：**
- 每日步数目标：4000-7000
- 运动类型：低冲击（游泳、瑜伽）
- 血压标准：允许130/85（为保证脑供血）
- 重点关注：防止跌倒，定期评估进度

---

## 🔄 工作流

### 新用户注册流程
```
1. 用户注册 POST /api/auth/register
   ↓
2. 系统自动创建基础健康档案（根据生日计算年龄组）
   ↓
3. 用户在首次登录时可更新详细档案信息
   POST /api/health-profile
   ↓
4. 系统自动匹配健康标准
   GET /api/health-profile/standards
   ↓
5. 用户上传健康数据并获取个性化分析
   GET /api/health-profile/analysis/personalized
```

### 医生添加建议流程
```
1. 医生登录系统
   ↓
2. 查看患者档案
   GET /api/health-profile (为患者)
   ↓
3. 添加医疗建议
   PUT /api/health-profile/doctor-notes
   ↓
4. 系统在后续分析中展示医生建议
```

---

## 🛠️ 维护建议

### 定期检查
- 监查数据库中 `user_health_profiles` 表的记录数
- 检查是否有用户档案信息不完整

### 更新标准
如需为特定人群添加新的标准：

```sql
INSERT INTO health_standards_reference (
  id, age_group, gender, activity_level,
  daily_steps_min, daily_steps_optimal, daily_steps_max,
  ...
) VALUES (UUID(), ...);
```

### 性能优化
- `v_user_personalized_standards` 视图会执行左连接，建议为 `user_health_profiles` 和 `health_standards_reference` 添加索引
- 考虑为常查询字段添加缓存

---

## 📊 预期数据

### health_standards_reference 预插入数据
系统预置了7组标准：

1. **成人女性 - 久坐** (5000步目标)
2. **成人男性 - 久坐** (6000步目标)
3. **成人 - 中等运动量** (10000步目标)
4. **成人 - 活跃** (15000步目标)
5. **中年 - 中等运动量** (8000步目标)
6. **老年 - 中等运动量** (7000步目标)
7. **孕期女性 - 轻度运动** (6000步目标)

可根据需要添加更多组合。

---

## 🔍 故障排除

### 问题1：用户档案查询返回 null

**原因：** 用户还未创建健康档案

**解决方案：**
```bash
POST /api/health-profile
Authorization: Bearer <token>

{
  "ageGroup": "adult",
  "activityLevel": "moderately_active"
}
```

### 问题2：个性化标准为 null

**原因：** `health_standards_reference` 表数据丢失或用户档案与任何标准都不匹配

**解决方案：**
1. 检查数据库：
```sql
SELECT COUNT(*) FROM health_standards_reference;
```
2. 如数据丢失，重新运行迁移脚本

### 问题3：API 返回 401 错误

**原因：** 未提供有效的认证令牌

**解决方案：** 确保请求头包含有效的 Bearer Token
```bash
Authorization: Bearer <valid_access_token>
```

---

## 📝 扩展功能建议

### 1. 多语言支持
- 为建议和标准添加 i18n 支持
- 支持英文、中文、日文等

### 2. 智能推荐
- 根据用户数据历史预测最适合的运动类型
- 基于天气条件的运动推荐

### 3. 家庭成员管理
- 家庭成员可共享数据
- 家庭健康报告

### 4. 可穿戴设备集成
- 与智能手表同步数据
- 实时健康提醒

### 5. 社交功能
- 用户可分享健康成就（可选隐私）
- 健康目标小组

---

## 📞 支持

如有问题，请参考：
- API文档：`PERSONALIZED_HEALTH_API.md`
- SQL脚本：`sql/04_personalized_health_standards.sql`
- 代码注释：查看相关源文件
