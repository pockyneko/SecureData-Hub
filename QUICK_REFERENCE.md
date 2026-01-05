# 快速参考卡 - 个性化健康评估系统

## 🎯 一句话概括

> 摒弃"10000步通用标准"的做法，根据用户的年龄、性别、运动水平和健康状况，自动分配个性化的健康标准。

---

## 📊 人群分类维度

### 年龄段 (5个)
- `child`: 儿童 (0-12岁)
- `teen`: 青少年 (13-18岁)
- `adult`: 成人 (19-40岁)
- `middle_age`: 中年 (41-65岁)
- `senior`: 老年 (65岁+)

### 运动水平 (5级)
- `sedentary`: 久坐
- `lightly_active`: 轻度活动
- `moderately_active`: 中等活动
- `very_active`: 经常运动
- `extremely_active`: 高强度运动

### 特殊条件 (5种)
- `has_cardiovascular_issues`: 心血管问题
- `has_diabetes`: 糖尿病
- `has_joint_issues`: 关节问题
- `is_pregnant`: 孕期
- `is_recovering`: 康复期

---

## 📈 标准示例对比

### 久坐上班族 vs 老年人

| 指标 | 久坐上班族 | 老年人 |
|------|----------|--------|
| 年龄 | 19-40岁 | 65岁+ |
| 步数目标 | **5000-7000** | **4000-7000** |
| 心率范围 | 60-80 bpm | 60-85 bpm |
| 睡眠 | 7-9小时 | 7-9小时 |
| 血压 | <120/80 | <130/85 |
| BMI | 18.5-24 | 18.5-27 |
| 重点 | 增加运动 | 防跌倒 |

---

## 🔄 API 速查

### 端点列表

```bash
# 获取档案
GET /api/health-profile
Authorization: Bearer <token>

# 创建/更新档案
POST /api/health-profile
Authorization: Bearer <token>
Content-Type: application/json
{ "ageGroup": "adult", "activityLevel": "moderately_active" }

# 获取个性化标准
GET /api/health-profile/standards
Authorization: Bearer <token>

# 获取分析报告
GET /api/health-profile/analysis/personalized
Authorization: Bearer <token>

# 删除档案
DELETE /api/health-profile
Authorization: Bearer <token>

# 更新医生建议
PUT /api/health-profile/doctor-notes
Authorization: Bearer <token>
Content-Type: application/json
{ "doctorNotes": "建议每天运动30分钟" }
```

---

## 📱 前端集成三步走

### 1️⃣ 检查档案
```javascript
GET /api/health-profile
// 如果返回 null，需要创建档案
```

### 2️⃣ 创建/编辑档案
```javascript
POST /api/health-profile
{
  "ageGroup": "adult",
  "activityLevel": "moderately_active",
  "healthCondition": "good"
}
```

### 3️⃣ 获取分析报告
```javascript
GET /api/health-profile/analysis/personalized
// 返回:
// - healthScore: 0-100
// - recommendations: 优先级排序的建议列表
// - assessments: 各项指标的详细评估
```

---

## 🗂️ 新增文件列表

### 后端代码
- `src/models/userHealthProfileModel.js` - 档案数据模型
- `src/services/personalizedHealthAnalysisService.js` - 分析服务
- `src/routes/personalizedHealthRoutes.js` - API 路由
- `sql/04_personalized_health_standards.sql` - 数据库脚本

### 文档
- `IMPLEMENTATION_SUMMARY.md` - 实现总结
- `PERSONALIZED_HEALTH_API.md` - API 详细文档
- `DEPLOYMENT_GUIDE.md` - 部署指南
- `ARCHITECTURE_DESIGN.md` - 架构设计
- `healthtrack_frontend/FRONTEND_INTEGRATION_GUIDE.md` - 前端指南

---

## 🚀 快速部署

```bash
# 1. 运行数据库迁移
mysql -u root -p < sql/04_personalized_health_standards.sql

# 2. 重启后端服务
npm restart
# 或 pm2 restart healthtrack-backend

# 3. 测试 API
curl -X GET http://localhost:3000/api/health-profile \
  -H "Authorization: Bearer <your_token>"
```

---

## 🔍 数据表速览

### user_health_profiles
存储用户的健康特征和个性化目标
- 一个用户一条记录
- UNIQUE(user_id)

### health_standards_reference
存储标准人群的健康标准范围
- 预置 7 组标准
- UNIQUE(age_group, gender, activity_level)

### v_user_personalized_standards
自动匹配用户的个性化标准（视图）
- 自动关联 users, user_health_profiles, health_standards_reference
- 支持个性化字段覆盖

---

## 📊 健康评分解读

| 分数范围 | 评价 | 表情 |
|---------|------|------|
| 80-100 | 很好！继续保持 | 🎉 |
| 60-79 | 还不错，还有改进空间 | 💪 |
| 0-59 | 需要关注，建议加强锻炼 | ⚠️ |

---

## 💡 常见场景速解

### 场景1: 久坐办公族
```json
{
  "ageGroup": "adult",
  "activityLevel": "sedentary",
  "healthCondition": "good"
}
→ 步数目标: 5000-7000
→ 建议: 从轻度运动开始，逐步增加
```

### 场景2: 老年人
```json
{
  "ageGroup": "senior",
  "activityLevel": "lightly_active",
  "healthCondition": "fair"
}
→ 步数目标: 4000-7000
→ 重点: 防跌倒，关注血压
```

### 场景3: 孕期妇女
```json
{
  "ageGroup": "adult",
  "isPregnant": true,
  "activityLevel": "lightly_active"
}
→ 步数目标: 4000-6000 (轻度散步)
→ 睡眠: 8-10小时
→ 饮水: 3000ml+
```

### 场景4: 康复患者
```json
{
  "ageGroup": "middle_age",
  "isRecovering": true,
  "activityLevel": "sedentary"
}
→ 循序渐进增加运动强度
→ 定期评估进度
```

---

## 🔐 安全提示

- ✅ 所有端点都需要认证 (Bearer Token)
- ✅ 用户只能访问自己的档案
- ✅ 医生可以添加医嘱，但不能修改用户其他数据
- ✅ 删除档案会级联删除关联数据

---

## 🐛 常见问题速答

**Q: 如何为用户自动创建档案?**
```
A: 用户注册时，系统自动根据 birthday 计算年龄组并创建。
```

**Q: 如何让用户自定义目标?**
```
A: POST /api/health-profile 时包含 personalized_steps_goal 等字段。
```

**Q: 孕期标准何时应用?**
```
A: 当 is_pregnant = true 时，系统自动应用孕期标准。
```

**Q: 医生建议在哪里展示?**
```
A: 在个性化分析报告中，doctor_notes 字段会包含医生建议。
```

**Q: 如何添加新的健康标准?**
```
A: INSERT 到 health_standards_reference 表中新的组合。
```

---

## 📞 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Flutter, Dart, Provider |
| 后端 | Node.js, Express.js |
| 数据库 | MySQL 8.0+ |
| API | REST, JWT Auth |

---

## 📚 文档导航

| 文档 | 用途 |
|------|------|
| `IMPLEMENTATION_SUMMARY.md` | 项目概览、核心优势 |
| `PERSONALIZED_HEALTH_API.md` | API 详细说明、示例 |
| `DEPLOYMENT_GUIDE.md` | 逐步部署、故障排除 |
| `ARCHITECTURE_DESIGN.md` | 系统设计、数据结构 |
| `FRONTEND_INTEGRATION_GUIDE.md` | 前端代码示例 |

---

## ⏱️ 预期工作量

| 工作项 | 预计时间 |
|--------|---------|
| 数据库部署 | 5 分钟 |
| 后端集成 | 已完成 ✅ |
| API 测试 | 15 分钟 |
| 前端集成 | 2-4 小时 |
| 前端 UI | 4-6 小时 |
| 测试&优化 | 4-6 小时 |
| **总计** | **~1-2 天** |

---

## ✨ 系统亮点

1. **科学性** - 基于医学指南
2. **个性化** - 适应不同人群
3. **灵活性** - 支持自定义和覆盖
4. **可扩展** - 易于添加新标准
5. **医疗友好** - 医生可干预

---

## 🎯 下一步

- [ ] 部署数据库迁移
- [ ] 测试所有 API 端点
- [ ] 前端开发档案编辑页面
- [ ] 前端开发分析展示页面
- [ ] 集成测试
- [ ] 用户培训

---

**版本**: 1.0  
**更新日期**: 2026-01-05  
**维护**: HealthTrack 团队
