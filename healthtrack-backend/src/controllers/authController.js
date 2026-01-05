/**
 * 认证控制器
 * 处理用户注册、登录、Token 刷新等
 */

const { UserModel } = require('../models');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../middlewares/auth');
const { generateMockDataForUser } = require('../services/mockDataService');

/**
 * 用户注册
 * POST /api/auth/register
 */
async function register(req, res) {
  const { username, email, password, nickname, height, gender, birthday, generateMockData } = req.body;

  // 检查用户名是否已存在
  if (await UserModel.usernameExists(username)) {
    return res.status(409).json({
      success: false,
      code: 'USERNAME_EXISTS',
      message: '用户名已被使用'
    });
  }

  // 检查邮箱是否已存在
  if (await UserModel.emailExists(email)) {
    return res.status(409).json({
      success: false,
      code: 'EMAIL_EXISTS',
      message: '邮箱已被注册'
    });
  }

  // 创建用户
  const user = await UserModel.create({
    username,
    email,
    password,
    nickname,
    height,
    gender,
    birthday
  });

  // 如果请求生成模拟数据（用于演示）
  let mockDataResult = null;
  if (generateMockData) {
    mockDataResult = await generateMockDataForUser(user.id, {
      days: 30,
      baseWeight: 70,
      includeAllTypes: true
    });
  }

  // 生成 Token
  const tokenPayload = {
    userId: user.id,
    username: user.username,
    email: user.email
  };
  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  res.status(201).json({
    success: true,
    message: '注册成功',
    data: {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        nickname: user.nickname
      },
      accessToken,
      refreshToken,
      mockData: mockDataResult
    }
  });
}

/**
 * 用户登录
 * POST /api/auth/login
 */
async function login(req, res) {
  const { identifier, password } = req.body;

  // 查找用户（支持用户名或邮箱）
  let user;
  if (identifier.includes('@')) {
    user = await UserModel.findByEmail(identifier);
  } else {
    user = await UserModel.findByUsername(identifier);
  }

  if (!user) {
    return res.status(401).json({
      success: false,
      code: 'INVALID_CREDENTIALS',
      message: '用户名/邮箱或密码错误'
    });
  }

  // 验证密码
  const isValidPassword = await UserModel.verifyPassword(password, user.password);
  if (!isValidPassword) {
    return res.status(401).json({
      success: false,
      code: 'INVALID_CREDENTIALS',
      message: '用户名或密码错误'
    });
  }

  // 生成 Token
  const tokenPayload = {
    userId: user.id,
    username: user.username,
    email: user.email
  };
  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  res.json({
    success: true,
    message: '登录成功',
    data: {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        height: user.height,
        gender: user.gender
      },
      accessToken,
      refreshToken
    }
  });
}

/**
 * 刷新 Token
 * POST /api/auth/refresh
 */
async function refreshToken(req, res) {
  const { refreshToken: token } = req.body;

  if (!token) {
    return res.status(400).json({
      success: false,
      code: 'MISSING_TOKEN',
      message: '请提供刷新令牌'
    });
  }

  const decoded = verifyRefreshToken(token);
  if (!decoded) {
    return res.status(401).json({
      success: false,
      code: 'INVALID_REFRESH_TOKEN',
      message: '刷新令牌无效或已过期'
    });
  }

  // 验证用户是否存在
  const user = await UserModel.findById(decoded.userId);
  if (!user) {
    return res.status(401).json({
      success: false,
      code: 'USER_NOT_FOUND',
      message: '用户不存在'
    });
  }

  // 生成新的 Token
  const tokenPayload = {
    userId: user.id,
    username: user.username,
    email: user.email
  };
  const newAccessToken = generateAccessToken(tokenPayload);
  const newRefreshToken = generateRefreshToken(tokenPayload);

  res.json({
    success: true,
    message: 'Token 刷新成功',
    data: {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken
    }
  });
}

/**
 * 获取当前用户信息
 * GET /api/auth/profile
 */
async function getProfile(req, res) {
  const user = await UserModel.findById(req.user.id);
  
  if (!user) {
    return res.status(404).json({
      success: false,
      code: 'USER_NOT_FOUND',
      message: '用户不存在'
    });
  }

  res.json({
    success: true,
    data: {
      id: user.id,
      username: user.username,
      email: user.email,
      nickname: user.nickname,
      avatar: user.avatar,
      height: user.height,
      gender: user.gender,
      birthday: user.birthday,
      createdAt: user.created_at
    }
  });
}

/**
 * 更新用户信息
 * PUT /api/auth/profile
 */
async function updateProfile(req, res) {
  const { nickname, height, gender, birthday } = req.body;
  
  const updated = await UserModel.update(req.user.id, {
    nickname,
    height,
    gender,
    birthday
  });

  if (!updated) {
    return res.status(400).json({
      success: false,
      code: 'UPDATE_FAILED',
      message: '更新失败'
    });
  }

  const user = await UserModel.findById(req.user.id);
  
  res.json({
    success: true,
    message: '资料更新成功',
    data: user
  });
}

/**
 * 修改密码
 * PUT /api/auth/password
 */
async function updatePassword(req, res) {
  const { oldPassword, newPassword } = req.body;

  // 获取完整用户信息（包含密码）
  const user = await UserModel.findByUsername(req.user.username);
  
  // 验证旧密码
  const isValidPassword = await UserModel.verifyPassword(oldPassword, user.password);
  if (!isValidPassword) {
    return res.status(401).json({
      success: false,
      code: 'INVALID_PASSWORD',
      message: '原密码错误'
    });
  }

  // 更新密码
  await UserModel.updatePassword(req.user.id, newPassword);

  res.json({
    success: true,
    message: '密码修改成功'
  });
}

module.exports = {
  register,
  login,
  refreshToken,
  getProfile,
  updateProfile,
  updatePassword
};
