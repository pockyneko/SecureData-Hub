# VS Code 后端检测快速参考

## 🚀 5 秒快速开始

### Windows
```bash
cd healthtrack-backend
check-backend.bat
```

### Mac/Linux
```bash
cd healthtrack-backend
bash check-backend.sh
```

---

## 📌 四大检测方案

### 方案 1️⃣: REST Client (最快) ⭐⭐⭐⭐⭐

**安装:**
```bash
code --install-extension humao.rest-client
```

**使用:**
1. 打开 `tests/personalized-health-api.http`
2. 修改 `@token = Bearer YOUR_JWT_TOKEN_HERE`
3. 点击每个请求上的 **Send Request** 按钮
4. 右侧面板查看响应

**优点:** 无需配置，开即用，可视化

---

### 方案 2️⃣: Jest 单元测试 (最全面) ⭐⭐⭐⭐⭐

**安装:**
```bash
npm install --save-dev jest
```

**运行:**
```bash
# 所有测试
npm test

# 监视模式
npm test -- --watch

# 覆盖率
npm test -- --coverage
```

**文件:** `tests/personalizedHealth.test.js`

**优点:** 自动化，重复可用，覆盖率统计

---

### 方案 3️⃣: 调试器 (最强大) ⭐⭐⭐⭐

**配置:** `.vscode/launch.json` 已预制

**使用:**
1. 在代码行号左侧点击设置断点 (红点)
2. 按 **F5** 启动调试
3. 使用调试控制:
   - **F10** - 单步
   - **F11** - 进入
   - **Shift+F11** - 跳出
   - **F5** - 继续

**优点:** 逐行调试，查看变量，排查问题

---

### 方案 4️⃣: 终端测试 (最灵活) ⭐⭐⭐

**启动服务:**
```bash
npm run dev
# 输出: Server running on http://localhost:3000
```

**curl 测试:**
```bash
curl -X GET http://localhost:3000/api/health-profile \
  -H "Authorization: Bearer <token>"
```

**压力测试:**
```bash
ab -n 100 -c 10 http://localhost:3000/api/health-profile
```

**优点:** 灵活，支持脚本化，集成 CI/CD

---

## 🎯 选择指南

| 场景 | 推荐方案 | 时间 |
|------|---------|------|
| 快速验证 API 是否响应 | REST Client | 1 分钟 |
| 验证所有功能逻辑 | Jest 单元测试 | 2 分钟 |
| 排查 bug，查看变量值 | 调试器 | 5-10 分钟 |
| 压力测试，性能测试 | 终端 curl/ab | 3-5 分钟 |

---

## 📋 完整检测流程

### 第 1 步: 环境检查 (2 分钟)
```bash
cd healthtrack-backend
npm install
npm test -- --listTests  # 列出所有测试
```

### 第 2 步: 启动服务 (1 分钟)
```bash
npm run dev
# 看到这条消息表示成功:
# ✓ Server running on http://localhost:3000
```

### 第 3 步: 数据库初始化 (1 分钟)
```bash
npm run init-db
npm run seed
```

### 第 4 步: API 测试 (2 分钟)
选择方案 1 或方案 4

### 第 5 步: 单元测试 (1 分钟)
```bash
npm test
```

### 第 6 步: 查看覆盖率 (1 分钟)
```bash
npm test -- --coverage
```

**总耗时: 10 分钟**

---

## 🔍 关键检查点

### ✅ API 端点检查
```http
GET http://localhost:3000/api/health-profile
Authorization: Bearer <token>
```

预期: `200 OK` + JSON 响应

### ✅ 创建档案检查
```json
{
  "ageGroup": "adult",
  "activityLevel": "sedentary",
  "healthCondition": "good"
}
```

预期: `201 Created` + profile data

### ✅ 获取分析检查
```http
GET http://localhost:3000/api/health-profile/analysis/personalized
Authorization: Bearer <token>
```

预期: `200 OK` + healthScore (0-100) + recommendations

### ✅ 错误处理检查
```http
GET http://localhost:3000/api/health-profile
# 不带 Authorization 头
```

预期: `401 Unauthorized`

---

## 🐛 常见问题速解

### Q: 连接被拒绝？
```bash
# 检查服务是否运行
netstat -ano | findstr :3000      # Windows
lsof -i :3000                     # Mac/Linux

# 如果没有，启动服务
npm run dev
```

### Q: JWT Token 无效？
```bash
# 获取新 token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Q: 数据库错误？
```bash
# 重新初始化
npm run init-db
npm run seed
```

### Q: 测试超时？
```bash
# 增加超时时间
npm test -- --testTimeout=30000
```

### Q: 如何调试异步函数？
在 `.vscode/launch.json` 中添加:
```json
"skipFiles": ["<node_internals>/**"]
```

---

## 📊 测试覆盖范围

**单元测试:** 30+ 个测试
```
✅ 健康评分 (3 个)
✅ 步数评估 (3 个)
✅ 心率评估 (3 个)
✅ 睡眠评估 (3 个)
✅ 血压评估 (3 个)
✅ BMI 评估 (3 个)
✅ 建议生成 (2 个)
✅ 年龄组 (5 个)
✅ 数据验证 (3 个)
✅ 集成场景 (3 个)
```

**API 测试:** 6 个端点
```
✅ POST   /api/health-profile
✅ GET    /api/health-profile
✅ GET    /api/health-profile/standards
✅ GET    /api/health-profile/analysis/personalized
✅ PUT    /api/health-profile/doctor-notes
✅ DELETE /api/health-profile
```

**错误测试:** 10+ 个场景
```
✅ 缺少认证 (401)
✅ 无效参数 (400)
✅ 资源不存在 (404)
✅ 内部错误 (500)
```

---

## 💻 VS Code 快捷键

| 快捷键 | 功能 |
|--------|------|
| Ctrl+` | 打开终端 |
| F5 | 启动调试 |
| F9 | 设置/移除断点 |
| F10 | 单步执行 |
| F11 | 单步进入 |
| Ctrl+Shift+D | 打开调试视图 |
| Ctrl+Shift+X | 打开扩展 |
| Ctrl+Shift+P | 打开命令面板 |

---

## 📚 相关文档

| 文档 | 内容 |
|------|------|
| `BACKEND_TESTING_GUIDE.md` | 详细的测试指南 (这是你现在看的) |
| `PERSONALIZED_HEALTH_API.md` | API 详细文档 |
| `ARCHITECTURE_DESIGN.md` | 系统架构设计 |
| `DEPLOYMENT_GUIDE.md` | 部署指南 |
| `.vscode/launch.json` | 调试配置 |
| `jest.config.js` | Jest 配置 |
| `tests/personalizedHealth.test.js` | 单元测试代码 |
| `tests/personalized-health-api.http` | REST 请求示例 |

---

## 🎓 学习路径

### 初级 (了解系统)
1. 运行 `npm run dev` 启动服务
2. 使用 REST Client 测试几个 API
3. 看看响应数据结构

### 中级 (验证功能)
1. 运行 `npm test` 看看测试结果
2. 修改一个测试用例
3. 使用调试器单步执行

### 高级 (添加新测试)
1. 在 `tests/` 中添加新测试
2. 使用 `npm test -- --watch` 开发模式
3. 达到 >80% 的代码覆盖率

---

## ✅ 部署检查清单

使用此清单确保一切就绪：

```
后端检测清单：
□ npm install 成功运行
□ npm run dev 能启动服务
□ npm test 所有测试通过
□ API 能正常响应 200
□ 错误处理返回正确状态码
□ 数据库连接正常
□ 代码覆盖率 > 70%
□ 没有安全警告
□ 没有性能瓶颈
```

---

## 🎉 完成!

现在你可以：
- ✅ 快速测试后端功能
- ✅ 验证 API 是否正常
- ✅ 排查问题
- ✅ 添加新测试
- ✅ 确保代码质量

**需要帮助?** 查看 `BACKEND_TESTING_GUIDE.md` 的详细内容

---

**最后更新:** 2026-01-05  
**状态:** 生产就绪 ✅

