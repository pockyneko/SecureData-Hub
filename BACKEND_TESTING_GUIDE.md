# VS Code 后端功能检测完整指南

## 📋 目录
1. [工具安装](#工具安装)
2. [方案 1: REST Client 插件测试](#方案-1-rest-client-插件测试)
3. [方案 2: Jest 单元测试](#方案-2-jest-单元测试)
4. [方案 3: 内置调试器](#方案-3-内置调试器)
5. [方案 4: 终端测试](#方案-4-终端测试)
6. [检测清单](#检测清单)
7. [常见问题](#常见问题)

---

## 工具安装

### 步骤 1: 安装必要的 VS Code 插件

**打开 VS Code → 扩展 → 搜索安装以下插件：**

| 插件名 | ID | 功能 |
|--------|-----|------|
| **REST Client** | `humao.rest-client` | 发送 HTTP 请求，测试 API ✨ 推荐 |
| **Jest Runner** | `orta.vscode-jest` | 运行单元测试 |
| **Thunder Client** | `rangav.vscode-thunder-client` | Postman 替代品 |
| **SQLite** | `alexcvzz.vscode-sqlite` | 查看/编辑数据库 |
| **GitLens** | `eamodio.gitlens` | Git 可视化 |
| **Prettier** | `esbenp.prettier-vscode` | 代码格式化 |

```bash
# 或使用命令行安装
code --install-extension humao.rest-client
code --install-extension orta.vscode-jest
code --install-extension rangav.vscode-thunder-client
```

### 步骤 2: 安装 npm 依赖

```bash
cd healthtrack-backend
npm install
# 如果需要测试框架
npm install --save-dev jest supertest
```

### 步骤 3: 验证安装

```bash
npm list
npm test --help
```

---

## 方案 1: REST Client 插件测试 ⭐ 最简单

### 优点
- ✅ 无需配置，开即用
- ✅ VS Code 内集成，不需要额外工具
- ✅ 支持变量和脚本
- ✅ 显示完整的请求/响应

### 使用步骤

**1. 打开测试文件**
```
healthtrack-backend/tests/personalized-health-api.http
```

**2. 设置环境变量**

在文件顶部编辑：
```http
@baseUrl = http://localhost:3000
@token = Bearer YOUR_JWT_TOKEN_HERE
@userId = 1
```

替换 `YOUR_JWT_TOKEN_HERE` 为实际的 JWT token

**如何获取 JWT Token？**
```bash
# 1. 注册新用户
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'

# 2. 登录获取 token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# 响应中的 token 字段即为 JWT Token
```

**3. 运行测试**

在每个请求上点击 **"Send Request"** 按钮：

```http
### 创建个性化档案
POST {{baseUrl}}/api/health-profile
Authorization: {{token}}
Content-Type: application/json

{
  "ageGroup": "adult",
  "activityLevel": "sedentary",
  ...
}
```

**4. 查看结果**

右侧面板会显示：
- ✅ 状态码 (200, 201, 400 等)
- ✅ 响应头
- ✅ 响应体 (JSON)
- ✅ 响应时间

### 示例输出

```
HTTP/1.1 201 Created
Content-Type: application/json
Content-Length: 245
Connection: keep-alive

{
  "success": true,
  "message": "Profile created/updated successfully",
  "data": {
    "userId": 1,
    "ageGroup": "adult",
    "activityLevel": "sedentary",
    "healthCondition": "good",
    ...
  }
}
```

### 测试场景

文件中已包含以下测试场景：

- ✅ **1.1** - 创建档案
- ✅ **1.2** - 获取档案
- ✅ **1.3** - 获取标准
- ✅ **1.4** - 获取分析
- ✅ **1.5** - 更新医嘱
- ✅ **1.6** - 删除档案
- ✅ **2.1-2.3** - 错误处理测试
- ✅ **3.1-3.3** - 数据库验证
- ✅ **4.x** - 完整场景

---

## 方案 2: Jest 单元测试 🧪 最全面

### 优点
- ✅ 自动化测试，可重复运行
- ✅ 覆盖率统计
- ✅ 测试所有分支
- ✅ 易于集成 CI/CD

### 使用步骤

**1. 查看测试文件**
```
healthtrack-backend/tests/personalizedHealth.test.js
```

**2. 在 VS Code 中运行测试**

**方法 A: 使用 Jest Runner 插件**

安装后，在测试文件中会出现 **"▶ Run"** 按钮：

```javascript
describe('Personalized Health Analysis Service', () => {
  test('应该正确计算基础评分', () => {
    // 点击这里的 "Run" 按钮
  });
});
```

**方法 B: 使用终端**

```bash
# 运行所有测试
npm test

# 运行特定文件
npm test -- personalizedHealth.test.js

# 监视模式（文件改变时自动重跑）
npm test -- --watch

# 显示覆盖率
npm test -- --coverage
```

**3. 查看结果**

```
PASS  tests/personalizedHealth.test.js
  Personalized Health Analysis Service
    健康评分计算
      ✓ 应该正确计算基础评分 (5ms)
      ✓ 健康状况差应该降低评分 (3ms)
      ✓ 超重应该降低评分 (2ms)
    步数评估
      ✓ 应该正确评估步数 (2ms)
      ...

Test Suites: 1 passed, 1 total
Tests:       27 passed, 27 total
Snapshots:   0 total
Time:        2.345 s
```

### 测试覆盖范围

```
✅ 健康评分计算 (3 个测试)
✅ 步数评估 (3 个测试)
✅ 心率评估 (3 个测试)
✅ 睡眠评估 (3 个测试)
✅ 血压评估 (3 个测试)
✅ BMI 评估 (3 个测试)
✅ 建议生成 (2 个测试)
✅ 年龄组计算 (5 个测试)
✅ 数据验证 (3 个测试)
✅ 集成场景 (3 个测试)

总计: 30+ 个测试
```

### 调试单个测试

在测试上添加 `.only`：

```javascript
test.only('应该正确计算基础评分', () => {
  // 只会运行这个测试
});
```

或添加 `.skip` 跳过：

```javascript
test.skip('应该正确计算基础评分', () => {
  // 这个测试会被跳过
});
```

---

## 方案 3: 内置调试器 🐛 最强大

### 优点
- ✅ 逐行调试
- ✅ 查看变量值
- ✅ 设置断点
- ✅ 跳过/步进代码

### 使用步骤

**1. 创建调试配置**

创建文件 `.vscode/launch.json`：

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "启动后端服务",
      "program": "${workspaceFolder}/healthtrack-backend/src/app.js",
      "restart": true,
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}/healthtrack-backend"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "运行测试",
      "program": "${workspaceFolder}/healthtrack-backend/node_modules/.bin/jest",
      "args": ["--runInBand"],
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}/healthtrack-backend"
    }
  ]
}
```

**2. 设置断点**

在代码中点击行号左侧，出现红点表示断点已设置：

```javascript
function calculatePersonalizedHealthScore(data) {
  // ← 点击这里设置断点
  let baseScore = 60;
  ...
}
```

**3. 启动调试**

按 **F5** 或点击 **"运行 → 启动调试"**

**4. 调试控制**

| 按键 | 功能 |
|------|------|
| **F10** | 单步（Step Over） |
| **F11** | 单步进入（Step Into） |
| **Shift+F11** | 单步跳出（Step Out） |
| **F5** | 继续（Continue） |
| **Shift+F5** | 停止 |

**5. 查看变量**

左侧面板显示：
- 📦 **Variables** - 当前作用域变量
- 📊 **Watch** - 监视表达式
- 📞 **Call Stack** - 调用栈

### 调试场景示例

**调试个性化分析函数：**

```javascript
// 在 src/services/personalizedHealthAnalysisService.js 设置断点
function getPersonalizedHealthAnalysis(userId) {
  // ← 断点 1: 检查 userId 值
  
  const profile = await UserHealthProfileModel.findByUserId(userId);
  // ← 断点 2: 检查 profile 对象
  
  const standards = await getPersonalizedStandards(userId);
  // ← 断点 3: 检查 standards 值
  
  const analysis = performAnalysis(data);
  // ← 断点 4: 检查分析结果
  
  return analysis;
}
```

---

## 方案 4: 终端测试 💻 最灵活

### 4.1 启动后端服务

```bash
cd healthtrack-backend

# 开发模式（支持自动重启）
npm run dev

# 生产模式
npm start
```

验证服务启动：
```
✓ Server running on http://localhost:3000
✓ Database connected
✓ API ready
```

### 4.2 使用 curl 测试

**测试创建档案：**
```bash
curl -X POST http://localhost:3000/api/health-profile \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "ageGroup": "adult",
    "activityLevel": "sedentary",
    "healthCondition": "good",
    "hasCardiovascularIssues": false
  }'
```

**预期响应：**
```json
{
  "success": true,
  "message": "Profile created/updated successfully",
  "data": { ... }
}
```

### 4.3 使用 Apache Bench 进行压力测试

```bash
# 并发 10 个请求，总共 100 个请求
ab -n 100 -c 10 \
  -H "Authorization: Bearer <token>" \
  http://localhost:3000/api/health-profile

# 输出结果
# Requests per second: 50 [#/sec]
# Time per request: 20 [ms]
# Failed requests: 0
```

### 4.4 使用 npm 脚本快速测试

在 `package.json` 中添加：

```json
{
  "scripts": {
    "test:api": "echo 'API testing with curl' && curl http://localhost:3000/api/health",
    "test:db": "mysql -u root -p < sql/04_personalized_health_standards.sql",
    "test:all": "npm run test && npm run test:api"
  }
}
```

运行：
```bash
npm run test:api
npm run test:db
npm run test:all
```

---

## 检测清单 ✅

使用此清单确保所有功能都已测试：

### 数据库检测
- [ ] 表创建成功 (user_health_profiles, health_standards_reference)
- [ ] 视图创建成功 (v_user_personalized_standards)
- [ ] 预置数据存在 (7 组标准)
- [ ] 外键约束正常
- [ ] 索引创建成功

```sql
-- 验证命令
SELECT COUNT(*) FROM user_health_profiles;
SELECT COUNT(*) FROM health_standards_reference;
SELECT COUNT(*) FROM v_user_personalized_standards;
```

### API 端点检测
- [ ] POST /api/health-profile - 创建档案 (201)
- [ ] GET /api/health-profile - 获取档案 (200)
- [ ] GET /api/health-profile/standards - 获取标准 (200)
- [ ] GET /api/health-profile/analysis/personalized - 获取分析 (200)
- [ ] PUT /api/health-profile/doctor-notes - 更新医嘱 (200)
- [ ] DELETE /api/health-profile - 删除档案 (200)

### 错误处理检测
- [ ] 缺少认证令牌返回 401
- [ ] 无效参数返回 400
- [ ] 资源不存在返回 404
- [ ] 内部错误返回 500

### 功能检测
- [ ] 年龄组自动计算正确
- [ ] 个性化标准自动匹配
- [ ] 健康评分在 0-100 范围内
- [ ] 建议按优先级排序
- [ ] 特殊条件处理正确

### 性能检测
- [ ] API 响应时间 < 500ms
- [ ] 数据库查询 < 100ms
- [ ] 并发处理能力 > 10 req/s
- [ ] 内存使用 < 500MB

### 安全检测
- [ ] JWT 验证工作
- [ ] 用户数据隔离正常
- [ ] SQL 注入防护有效
- [ ] 输入验证完整

---

## 常见问题

### Q1: 如何获取 JWT Token？

**方法 1: 使用 REST Client**
```http
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

响应中的 `token` 字段即为 JWT

**方法 2: 使用 curl**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Q2: 如何查看数据库？

使用 SQLite 插件或命令行：
```bash
mysql -u root -p
use healthtrack;
SELECT * FROM user_health_profiles;
```

### Q3: 测试失败怎么办？

**检查清单：**
1. ✅ 后端服务是否运行？ (`npm run dev`)
2. ✅ 数据库是否正确初始化？ (`npm run init-db`)
3. ✅ JWT Token 是否有效？
4. ✅ 查看错误日志
5. ✅ 检查防火墙

### Q4: 如何调试异步代码？

在 `jest.config.js` 中配置：
```javascript
{
  testTimeout: 30000  // 增加超时时间
}
```

在测试中使用 `async/await`：
```javascript
test('异步测试', async () => {
  const result = await someAsyncFunction();
  expect(result).toBe(expected);
});
```

### Q5: 如何生成代码覆盖率报告？

```bash
npm test -- --coverage

# 输出
# ├── Stmts   : 85.5%  (语句)
# ├── Branch  : 82.3%  (分支)
# ├── Funcs   : 88.7%  (函数)
# └── Lines   : 85.2%  (行)
```

### Q6: REST Client 找不到？

重启 VS Code：
```bash
# 或完全卸载重装
code --uninstall-extension humao.rest-client
code --install-extension humao.rest-client
```

---

## 快速参考

### 常用命令

```bash
# 启动服务
npm run dev

# 运行所有测试
npm test

# 监视模式测试
npm test -- --watch

# 查看覆盖率
npm test -- --coverage

# 初始化数据库
npm run init-db

# 种子数据
npm run seed
```

### 快捷键

| 功能 | Windows | Mac |
|------|---------|-----|
| 打开命令面板 | Ctrl+Shift+P | Cmd+Shift+P |
| 打开终端 | Ctrl+` | Ctrl+` |
| 调试开始/暂停 | F5 | F5 |
| 设置断点 | F9 | F9 |
| 单步执行 | F10 | F10 |

### 有用的命令

```bash
# VS Code
Ctrl+Shift+P > REST Client: Send Request
Ctrl+Shift+P > Jest: Run All Tests
Ctrl+Shift+P > Debug: Start Debugging

# 终端
npm test -- --testNamePattern="个性化"
npm test -- --coverage --silent
```

---

## 总结

| 方案 | 难度 | 速度 | 覆盖率 | 推荐用途 |
|------|------|------|--------|---------|
| **REST Client** | ⭐ | ⚡⚡⚡ | 低 | 快速验证 API |
| **Jest 单元测试** | ⭐⭐ | ⚡⚡ | 高 | 完整功能验证 |
| **调试器** | ⭐⭐⭐ | ⚡ | 中 | 问题排查 |
| **终端测试** | ⭐⭐ | ⚡⚡ | 中 | 集成/压力测试 |

**推荐工作流：**
1. 👉 使用 **REST Client** 快速测试 API (1 分钟)
2. 👉 运行 **Jest 单元测试** 验证逻辑 (2 分钟)
3. 👉 使用 **调试器** 排查问题 (按需)
4. 👉 **终端** 进行压力和集成测试 (按需)

---

**需要帮助？** 查看相关文档：
- 📖 PERSONALIZED_HEALTH_API.md
- 📖 DEPLOYMENT_GUIDE.md
- 📖 ARCHITECTURE_DESIGN.md

