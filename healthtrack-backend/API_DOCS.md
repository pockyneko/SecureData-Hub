# HealthTrack API 接口文档

## 基础信息

- **Base URL**: `http://localhost:3000/api`
- **数据格式**: JSON
- **认证方式**: Bearer Token (JWT)

## 认证说明

需要认证的接口，请在请求头中添加：
```
Authorization: Bearer <access_token>
```

---

## 1. 认证接口

### 1.1 用户注册

**POST** `/auth/register`

**请求体：**
```json
{
  "username": "zhangsan",
  "email": "zhangsan@example.com",
  "password": "123456",
  "nickname": "张三",
  "height": 175,
  "gender": "male",
  "birthday": "1995-06-15",
  "generateMockData": true
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 用户名，3-20字符，字母数字下划线 |
| email | string | 是 | 邮箱 |
| password | string | 是 | 密码，6-50字符 |
| nickname | string | 否 | 昵称 |
| height | number | 否 | 身高(cm)，50-250 |
| gender | string | 否 | 性别: male/female/other |
| birthday | string | 否 | 生日，YYYY-MM-DD |
| generateMockData | boolean | 否 | 是否生成30天模拟数据 |

**成功响应：**
```json
{
  "success": true,
  "message": "注册成功",
  "data": {
    "user": {
      "id": "uuid",
      "username": "zhangsan",
      "email": "zhangsan@example.com",
      "nickname": "张三"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "mockData": {
      "success": true,
      "insertedCount": 240,
      "message": "成功生成 240 条模拟数据"
    }
  }
}
```

### 1.2 用户登录

**POST** `/auth/login`

**请求体：**
```json
{
  "username": "zhangsan",
  "password": "123456"
}
```

**成功响应：**
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "user": {
      "id": "uuid",
      "username": "zhangsan",
      "email": "zhangsan@example.com",
      "nickname": "张三",
      "avatar": null,
      "height": 175,
      "gender": "male"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

### 1.3 刷新 Token

**POST** `/auth/refresh`

**请求体：**
```json
{
  "refreshToken": "eyJhbGc..."
}
```

**成功响应：**
```json
{
  "success": true,
  "message": "Token 刷新成功",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

### 1.4 获取个人信息

**GET** `/auth/profile`

**需要认证**

**成功响应：**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "zhangsan",
    "email": "zhangsan@example.com",
    "nickname": "张三",
    "avatar": null,
    "height": 175,
    "gender": "male",
    "birthday": "1995-06-15",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### 1.5 更新个人信息

**PUT** `/auth/profile`

**需要认证**

**请求体：**
```json
{
  "nickname": "小张",
  "height": 176,
  "gender": "male",
  "birthday": "1995-06-15"
}
```

### 1.6 修改密码

**PUT** `/auth/password`

**需要认证**

**请求体：**
```json
{
  "oldPassword": "123456",
  "newPassword": "654321"
}
```

---

## 2. 健康数据接口

### 2.1 获取健康记录列表

**GET** `/health/records`

**需要认证**

**查询参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | string | 否 | 数据类型 |
| startDate | string | 否 | 开始日期 YYYY-MM-DD |
| endDate | string | 否 | 结束日期 YYYY-MM-DD |
| limit | number | 否 | 每页条数，默认100 |
| offset | number | 否 | 偏移量，默认0 |

**数据类型枚举：**
- `weight` - 体重(kg)
- `steps` - 步数
- `blood_pressure_sys` - 收缩压(mmHg)
- `blood_pressure_dia` - 舒张压(mmHg)
- `heart_rate` - 心率(bpm)
- `sleep` - 睡眠时长(小时)
- `water` - 饮水量(ml)
- `calories` - 卡路里(kcal)

**示例请求：**
```
GET /api/health/records?type=weight&startDate=2024-01-01&endDate=2024-01-31&limit=30
```

**成功响应：**
```json
{
  "success": true,
  "data": {
    "records": [
      {
        "id": "uuid",
        "type": "weight",
        "value": 70.5,
        "note": "早起空腹测量",
        "recordDate": "2024-01-15",
        "createdAt": "2024-01-15T08:00:00.000Z"
      }
    ],
    "pagination": {
      "total": 30,
      "limit": 30,
      "offset": 0
    }
  }
}
```

### 2.2 创建健康记录

**POST** `/health/records`

**需要认证**

**请求体：**
```json
{
  "type": "weight",
  "value": 70.5,
  "note": "早起空腹测量",
  "recordDate": "2024-01-15"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | string | 是 | 数据类型 |
| value | number | 是 | 数值，非负数 |
| note | string | 否 | 备注，最多500字符 |
| recordDate | string | 否 | 记录日期，默认今天 |

**成功响应：**
```json
{
  "success": true,
  "message": "记录创建成功",
  "data": {
    "id": "uuid",
    "userId": "user-uuid",
    "type": "weight",
    "value": 70.5,
    "note": "早起空腹测量",
    "recordDate": "2024-01-15"
  }
}
```

### 2.3 批量创建健康记录

**POST** `/health/records/batch`

**需要认证**

**请求体：**
```json
{
  "records": [
    { "type": "weight", "value": 70.5, "recordDate": "2024-01-15" },
    { "type": "steps", "value": 8500, "recordDate": "2024-01-15" },
    { "type": "sleep", "value": 7.5, "recordDate": "2024-01-15" }
  ]
}
```

### 2.4 更新健康记录

**PUT** `/health/records/:id`

**需要认证**

**请求体：**
```json
{
  "value": 70.2,
  "note": "更新备注"
}
```

### 2.5 删除健康记录

**DELETE** `/health/records/:id`

**需要认证**

### 2.6 获取健康分析报告

**GET** `/health/analysis`

**需要认证**

**成功响应：**
```json
{
  "success": true,
  "data": {
    "user": {
      "nickname": "张三",
      "height": 175,
      "gender": "male"
    },
    "currentStatus": {
      "weight": 70.5,
      "steps": 8500,
      "heartRate": 72,
      "bloodPressure": "118/75",
      "sleep": 7.5
    },
    "bmiAnalysis": {
      "bmi": 23.0,
      "min": 18.5,
      "max": 24,
      "label": "正常",
      "advice": "继续保持健康的生活方式"
    },
    "statistics": {
      "weekly": {
        "avgSteps": 7800,
        "totalSteps": 54600,
        "avgWeight": 70.3
      },
      "monthly": {
        "avgSteps": 7500,
        "totalSteps": 225000,
        "avgWeight": 70.5,
        "weightChange": 0.8
      }
    },
    "goals": {
      "stepsGoal": 10000,
      "waterGoal": 2500,
      "sleepGoal": 8,
      "caloriesGoal": 2200,
      "weightGoal": 68
    },
    "healthScore": 82,
    "recommendations": [
      {
        "category": "运动建议",
        "priority": "medium",
        "advice": "继续保持！您距离每日10000步的目标只差1500步了。"
      }
    ],
    "analyzedAt": "2024-01-15T10:00:00.000Z"
  }
}
```

### 2.7 获取趋势数据

**GET** `/health/trends/:type`

**需要认证**

**路径参数：**
- `type` - 数据类型（weight, steps, heart_rate 等）

**查询参数：**
- `period` - 时间范围：week(默认), month, quarter

**示例请求：**
```
GET /api/health/trends/weight?period=month
```

**成功响应：**
```json
{
  "success": true,
  "data": {
    "type": "weight",
    "period": "month",
    "startDate": "2023-12-15",
    "endDate": "2024-01-15",
    "data": [
      { "date": "2023-12-15", "value": 71.2, "count": 1 },
      { "date": "2023-12-16", "value": 71.0, "count": 1 },
      { "date": "2024-01-15", "value": 70.5, "count": 1 }
    ]
  }
}
```

### 2.8 获取今日概览

**GET** `/health/today`

**需要认证**

**成功响应：**
```json
{
  "success": true,
  "data": {
    "date": "2024-01-15",
    "summary": {
      "steps": { "type": "steps", "value": 8500, "count": 1, "latest": 8500 },
      "water": { "type": "water", "value": 1800, "count": 3, "latest": 500 },
      "weight": { "type": "weight", "value": 70.5, "count": 1, "latest": 70.5 }
    },
    "goals": {
      "stepsGoal": 10000,
      "waterGoal": 2500,
      "sleepGoal": 8
    },
    "goalProgress": {
      "steps": { "current": 8500, "goal": 10000, "percentage": 85 },
      "water": { "current": 1800, "goal": 2500, "percentage": 72 },
      "sleep": { "current": 7.5, "goal": 8, "percentage": 94 }
    }
  }
}
```

### 2.9 获取/更新用户目标

**GET** `/health/goals`

**PUT** `/health/goals`

**需要认证**

**请求体（PUT）：**
```json
{
  "stepsGoal": 10000,
  "waterGoal": 2500,
  "sleepGoal": 8,
  "caloriesGoal": 2200,
  "weightGoal": 68
}
```

### 2.10 生成模拟数据

**POST** `/health/mock-data`

**需要认证**

**请求体：**
```json
{
  "days": 30,
  "demoMode": false
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| days | number | 否 | 生成天数，默认30 |
| demoMode | boolean | 否 | 演示模式（数据趋势更明显） |

---

## 3. 公开服务接口

### 3.1 获取健康百科列表

**GET** `/public/tips`

**无需认证**

**查询参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | string | 否 | 分类筛选 |
| limit | number | 否 | 每页条数，默认50 |
| offset | number | 否 | 偏移量，默认0 |

**成功响应：**
```json
{
  "success": true,
  "data": {
    "tips": [
      {
        "id": "uuid",
        "title": "均衡饮食的重要性",
        "content": "均衡饮食是维持身体健康的基础...",
        "category": "营养膳食",
        "imageUrl": null,
        "createdAt": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

### 3.2 获取健康百科分类

**GET** `/public/tips/categories`

**无需认证**

**成功响应：**
```json
{
  "success": true,
  "data": ["营养膳食", "运动健身", "睡眠健康", "心理健康", "慢病预防"]
}
```

### 3.3 获取运动推荐

**GET** `/public/exercises/recommendations`

**无需认证**

**查询参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| weather | string | 否 | 天气：sunny/cloudy/rainy/snowy/hot/cold |
| timeSlot | string | 否 | 时段：morning/afternoon/evening/night |
| limit | number | 否 | 返回数量，默认5 |

**示例请求：**
```
GET /api/public/exercises/recommendations?weather=sunny&timeSlot=morning
```

**成功响应：**
```json
{
  "success": true,
  "data": {
    "conditions": {
      "weather": "晴天",
      "timeSlot": "早晨"
    },
    "message": "根据当前晴天早晨为您推荐以下运动：",
    "recommendations": [
      {
        "id": "uuid",
        "name": "户外跑步",
        "description": "在公园或跑道上进行慢跑或快跑...",
        "intensity": "medium",
        "duration": 30,
        "caloriesBurned": 300,
        "imageUrl": null
      }
    ]
  }
}
```

### 3.4 获取每日健康贴士

**GET** `/public/daily-tip`

**无需认证**

**成功响应：**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "每天运动30分钟",
    "content": "世界卫生组织建议成年人每周至少进行150分钟中等强度有氧运动...",
    "category": "运动健身"
  }
}
```

---

## 4. 错误响应

### 错误码说明

| HTTP 状态码 | 错误码 | 说明 |
|-------------|--------|------|
| 400 | VALIDATION_ERROR | 请求参数验证失败 |
| 401 | UNAUTHORIZED | 未提供认证令牌 |
| 401 | TOKEN_INVALID | 令牌无效 |
| 401 | TOKEN_EXPIRED | 令牌已过期 |
| 401 | INVALID_CREDENTIALS | 用户名或密码错误 |
| 404 | NOT_FOUND | 资源不存在 |
| 409 | USERNAME_EXISTS | 用户名已存在 |
| 409 | EMAIL_EXISTS | 邮箱已被注册 |
| 429 | RATE_LIMIT_EXCEEDED | 请求过于频繁 |
| 500 | INTERNAL_ERROR | 服务器内部错误 |

### 错误响应格式

```json
{
  "success": false,
  "code": "VALIDATION_ERROR",
  "message": "请求参数验证失败",
  "errors": [
    {
      "field": "email",
      "message": "请输入有效的邮箱地址"
    }
  ]
}
```

---

## 5. 示例：完整使用流程

```bash
# 1. 注册账号（可选择生成模拟数据）
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@test.com","password":"123456","generateMockData":true}'

# 2. 登录获取 Token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"123456"}'

# 3. 获取健康分析报告
curl -X GET http://localhost:3000/api/health/analysis \
  -H "Authorization: Bearer <your_access_token>"

# 4. 记录今日体重
curl -X POST http://localhost:3000/api/health/records \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_access_token>" \
  -d '{"type":"weight","value":70.5}'

# 5. 获取体重趋势
curl -X GET "http://localhost:3000/api/health/trends/weight?period=month" \
  -H "Authorization: Bearer <your_access_token>"

# 6. 获取运动推荐（无需认证）
curl -X GET "http://localhost:3000/api/public/exercises/recommendations?weather=sunny&timeSlot=morning"
```
