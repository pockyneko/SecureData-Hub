/**
 * HealthTrack 后端服务入口
 * 
 * 功能：
 * - 用户认证 (JWT)
 * - 健康数据管理
 * - 健康分析报告
 * - 公开健康百科服务
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const path = require('path');

// 加载配置
const config = require('./config');
const { testConnection } = require('./config/database');

// 导入路由
const { authRoutes, healthRoutes, publicRoutes } = require('./routes');

// 导入中间件
const { notFoundHandler, errorHandler } = require('./middlewares');

// 创建 Express 应用
const app = express();

// ========================================
// 中间件配置
// ========================================

// 安全头
app.use(helmet());

// 跨域配置
app.use(cors({
  origin: config.cors.origin,
  credentials: config.cors.credentials,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// 请求日志
if (config.server.env !== 'test') {
  app.use(morgan('dev'));
}

// 请求体解析
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 速率限制
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分钟
  max: 100, // 每个 IP 最多 100 次请求
  message: {
    success: false,
    code: 'RATE_LIMIT_EXCEEDED',
    message: '请求过于频繁，请稍后再试'
  }
});
app.use('/api/', limiter);

// 静态文件（上传的文件）
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ========================================
// API 路由
// ========================================

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'HealthTrack API 运行正常',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// 认证路由
app.use('/api/auth', authRoutes);

// 健康数据路由（需要认证）
app.use('/api/health', healthRoutes);

// 公开服务路由
app.use('/api/public', publicRoutes);

// API 文档（简易版）
app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: 'HealthTrack API v1.0.0',
    endpoints: {
      auth: {
        'POST /api/auth/register': '用户注册',
        'POST /api/auth/login': '用户登录',
        'POST /api/auth/refresh': '刷新 Token',
        'GET /api/auth/profile': '获取用户信息 [需认证]',
        'PUT /api/auth/profile': '更新用户信息 [需认证]',
        'PUT /api/auth/password': '修改密码 [需认证]'
      },
      health: {
        'GET /api/health/records': '获取健康记录 [需认证]',
        'POST /api/health/records': '创建健康记录 [需认证]',
        'PUT /api/health/records/:id': '更新健康记录 [需认证]',
        'DELETE /api/health/records/:id': '删除健康记录 [需认证]',
        'GET /api/health/analysis': '获取健康分析报告 [需认证]',
        'GET /api/health/trends/:type': '获取趋势数据 [需认证]',
        'GET /api/health/today': '今日概览 [需认证]',
        'GET /api/health/goals': '获取目标 [需认证]',
        'PUT /api/health/goals': '更新目标 [需认证]',
        'POST /api/health/mock-data': '生成模拟数据 [需认证]'
      },
      public: {
        'GET /api/public/tips': '健康百科列表',
        'GET /api/public/tips/:id': '健康百科详情',
        'GET /api/public/exercises': '运动建议列表',
        'GET /api/public/exercises/recommendations': '运动推荐',
        'GET /api/public/daily-tip': '每日健康小贴士'
      }
    },
    documentation: 'https://github.com/healthtrack/api-docs'
  });
});

// ========================================
// 错误处理
// ========================================

// 404 处理
app.use(notFoundHandler);

// 全局错误处理
app.use(errorHandler);

// ========================================
// 启动服务器
// ========================================

async function startServer() {
  // 测试数据库连接
  const dbConnected = await testConnection();
  if (!dbConnected) {
    console.error('❌ 数据库连接失败，请检查配置');
    process.exit(1);
  }

  const PORT = config.server.port;
  app.listen(PORT, () => {
    console.log('========================================');
    console.log('🏥 HealthTrack 后端服务启动成功');
    console.log(`📍 地址: http://localhost:${PORT}`);
    console.log(`🔧 环境: ${config.server.env}`);
    console.log(`📚 API 文档: http://localhost:${PORT}/api`);
    console.log('========================================');
  });
}

// 启动
startServer();

module.exports = app;
