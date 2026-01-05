# HealthTrack 健康追踪系统 - 后端服务

<p align="center">
  <img src="https://img.shields.io/badge/Node.js-18+-green.svg" alt="Node.js">
  <img src="https://img.shields.io/badge/Express-4.18-blue.svg" alt="Express">
  <img src="https://img.shields.io/badge/MySQL-8.0+-orange.svg" alt="MySQL">
  <img src="https://img.shields.io/badge/JWT-Auth-red.svg" alt="JWT">
</p>

## 📋 项目简介

HealthTrack 是一款基于 Node.js 的健康追踪后端服务，为移动端应用提供完整的 RESTful API，支持：

- 🔐 **安全认证**：JWT Token 机制，水平权限保护
- 📊 **健康数据管理**：体重、步数、血压、心率等多维度数据记录
- 📈 **智能分析**：BMI 计算、健康评分、趋势分析、个性化建议
- 📚 **健康百科**：丰富的健康知识库
- 🏃 **运动建议**：根据天气、时段推荐适宜运动

## 🏗️ 技术架构

```
healthtrack-backend/
├── src/
│   ├── app.js                 # 应用入口
│   ├── config/                # 配置文件
│   │   ├── index.js          # 主配置
│   │   └── database.js       # 数据库配置
│   ├── controllers/           # 控制器层
│   │   ├── authController.js
│   │   ├── healthController.js
│   │   └── publicController.js
│   ├── middlewares/           # 中间件
│   │   ├── auth.js           # JWT 认证
│   │   ├── validator.js      # 请求验证
│   │   └── errorHandler.js   # 错误处理
│   ├── models/                # 数据模型
│   │   ├── userModel.js
│   │   ├── healthRecordModel.js
│   │   ├── userGoalModel.js
│   │   ├── healthTipModel.js
│   │   └── exerciseAdviceModel.js
│   ├── routes/                # 路由定义
│   │   ├── authRoutes.js
│   │   ├── healthRoutes.js
│   │   └── publicRoutes.js
│   ├── services/              # 业务服务
│   │   ├── healthAnalysisService.js
│   │   └── mockDataService.js
│   └── scripts/               # 脚本工具
│       ├── initDatabase.js
│       └── seedData.js
├── sql/                       # SQL 脚本
│   ├── 01_schema.sql         # 表结构
│   ├── 02_seed_data.sql      # 初始数据
│   └── 03_demo_data.sql      # 演示数据
├── package.json
├── .env.example
└── README.md
```

## 🚀 快速开始

### 环境要求

- Node.js >= 18.0
- MySQL >= 8.0
- npm >= 9.0

### 安装步骤

1. **克隆项目并安装依赖**

```bash
cd healthtrack-backend
npm install
```

2. **配置环境变量**

```bash
# 复制配置模板
cp .env.example .env

# 编辑 .env 文件，填写数据库配置
```

主要配置项：
```env
# 服务器配置
PORT=3000
NODE_ENV=development

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=healthtrack

# JWT 配置（生产环境请修改）
JWT_SECRET=your_super_secret_key
JWT_EXPIRES_IN=7d
```

3. **初始化数据库**

方式一：使用 Node.js 脚本
```bash
# 创建表结构
npm run init-db

# 导入初始数据
npm run seed
```

方式二：使用 SQL 文件
```bash
# 登录 MySQL
mysql -u root -p

# 执行 SQL 脚本
source sql/01_schema.sql
source sql/02_seed_data.sql
source sql/03_demo_data.sql  # 可选：演示数据
```

4. **启动服务**

```bash
# 开发模式（热重载）
npm run dev

# 生产模式
npm start
```

5. **验证服务**

访问 http://localhost:3000/api 查看 API 文档

## 📚 API 接口文档

### 认证接口 (Public)

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/api/auth/register` | 用户注册 |
| POST | `/api/auth/login` | 用户登录 |
| POST | `/api/auth/refresh` | 刷新 Token |

### 用户接口 (需认证)

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/auth/profile` | 获取个人信息 |
| PUT | `/api/auth/profile` | 更新个人信息 |
| PUT | `/api/auth/password` | 修改密码 |

### 健康数据接口 (需认证)

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/health/records` | 获取健康记录列表 |
| POST | `/api/health/records` | 创建健康记录 |
| PUT | `/api/health/records/:id` | 更新健康记录 |
| DELETE | `/api/health/records/:id` | 删除健康记录 |
| GET | `/api/health/analysis` | 获取健康分析报告 |
| GET | `/api/health/trends/:type` | 获取趋势数据 |
| GET | `/api/health/today` | 获取今日概览 |
| GET | `/api/health/goals` | 获取健康目标 |
| PUT | `/api/health/goals` | 更新健康目标 |
| POST | `/api/health/mock-data` | 生成模拟数据 |

### 公开服务接口 (无需认证)

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/public/tips` | 健康百科列表 |
| GET | `/api/public/tips/:id` | 健康百科详情 |
| GET | `/api/public/exercises` | 运动建议列表 |
| GET | `/api/public/exercises/recommendations` | 运动推荐 |
| GET | `/api/public/daily-tip` | 每日健康贴士 |

## 🔒 安全设计

### JWT 水平权限保护

系统采用 JWT + 水平权限保护机制，确保用户只能访问自己的数据：

```javascript
// 中间件从 Token 解析用户 ID
req.user = {
  id: decoded.userId,  // 从 Token 解析，非前端传参
  username: decoded.username
};

// 数据库查询强制使用 Token 中的 userId
const records = await query(
  'SELECT * FROM health_records WHERE user_id = ?',
  [req.user.id]  // 使用 Token 解析的 ID
);
```

**安全特性：**
- 用户 A 无法通过修改请求参数访问用户 B 的数据
- 所有敏感操作都基于 Token 中的用户身份
- 支持 Token 过期和刷新机制

## 📊 数据模型

### 支持的健康数据类型

| 类型 | 说明 | 单位 |
|------|------|------|
| weight | 体重 | kg |
| steps | 步数 | 步 |
| blood_pressure_sys | 收缩压 | mmHg |
| blood_pressure_dia | 舒张压 | mmHg |
| heart_rate | 心率 | bpm |
| sleep | 睡眠时长 | 小时 |
| water | 饮水量 | ml |
| calories | 卡路里摄入 | kcal |

### BMI 分类标准

| BMI 范围 | 分类 | 建议 |
|----------|------|------|
| < 18.5 | 偏瘦 | 适当增加营养摄入 |
| 18.5 - 24 | 正常 | 继续保持健康生活方式 |
| 24 - 28 | 偏胖 | 增加运动，控制饮食 |
| >= 28 | 肥胖 | 咨询医生，制定减重计划 |

## 🧪 测试

### 使用 Postman 测试

1. **注册用户**
```bash
POST http://localhost:3000/api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "123456",
  "nickname": "测试用户",
  "height": 175,
  "generateMockData": true
}
```

2. **登录获取 Token**
```bash
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "123456"
}
```

3. **获取健康分析报告**
```bash
GET http://localhost:3000/api/health/analysis
Authorization: Bearer <your_access_token>
```

### 演示账号

如果导入了演示数据 (03_demo_data.sql)：
- 用户名: `demo` / 密码: `demo123456`
- 用户名: `test` / 密码: `demo123456`

## 🐳 Docker 部署

```yaml
# docker-compose.yml
version: '3.8'
services:
  healthtrack-api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_USER=healthtrack
      - DB_PASSWORD=your_password
      - DB_NAME=healthtrack
      - JWT_SECRET=your_production_secret
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=root_password
      - MYSQL_DATABASE=healthtrack
      - MYSQL_USER=healthtrack
      - MYSQL_PASSWORD=your_password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./sql:/docker-entrypoint-initdb.d

volumes:
  mysql_data:
```

## 📝 更新日志

### v1.0.0 (2024-12)
- 初始版本发布
- 用户认证系统 (JWT)
- 健康数据 CRUD
- BMI 计算和健康分析
- 健康百科和运动建议
- 模拟数据生成

## 📄 许可证

MIT License

## 👥 贡献者

HealthTrack 开发团队

---

如有问题或建议，请提交 Issue 或 Pull Request。
