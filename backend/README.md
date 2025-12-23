# SecureData Hub 后端

本目录为 Node.js + Express 实现的后端服务，支持 JWT 认证、用户注册/登录、私有数据接口。

## 主要依赖
- express
- jsonwebtoken
- bcrypt
- mysql2
- dotenv
- cors

## 启动方式
1. 安装依赖：`npm install`
2. 启动服务：`node index.js`

## 目录结构
- index.js：后端入口
- .env：环境变量（需自行创建）
- routes/：路由目录（后续补充）
- models/：数据模型目录（后续补充）

## 说明
如需切换为 MongoDB，请安装 mongoose 并调整相关数据库操作。
