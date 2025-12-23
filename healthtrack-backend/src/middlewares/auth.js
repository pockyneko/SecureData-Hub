/**
 * JWT 认证中间件
 * 实现 Token 签发、验证、刷新
 */

const jwt = require('jsonwebtoken');
const config = require('../config');

/**
 * 生成访问令牌
 */
function generateAccessToken(payload) {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn,
    issuer: 'HealthTrack'
  });
}

/**
 * 生成刷新令牌
 */
function generateRefreshToken(payload) {
  return jwt.sign(payload, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpiresIn,
    issuer: 'HealthTrack'
  });
}

/**
 * 验证访问令牌
 */
function verifyAccessToken(token) {
  try {
    return jwt.verify(token, config.jwt.secret);
  } catch (error) {
    return null;
  }
}

/**
 * 验证刷新令牌
 */
function verifyRefreshToken(token) {
  try {
    return jwt.verify(token, config.jwt.refreshSecret);
  } catch (error) {
    return null;
  }
}

/**
 * JWT 认证中间件
 * 验证请求头中的 Authorization: Bearer <token>
 * 【水平权限保护核心】从 Token 中解出 userId，而非信任前端传参
 */
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      code: 'UNAUTHORIZED',
      message: '未提供认证令牌'
    });
  }

  // 检查 Bearer 格式
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({
      success: false,
      code: 'INVALID_TOKEN_FORMAT',
      message: '认证令牌格式错误'
    });
  }

  const token = parts[1];
  const decoded = verifyAccessToken(token);

  if (!decoded) {
    return res.status(401).json({
      success: false,
      code: 'TOKEN_INVALID',
      message: '认证令牌无效或已过期'
    });
  }

  // 【关键】将解析出的用户信息附加到请求对象
  // 后续所有数据操作都使用 req.user.id，而非请求参数中的 userId
  req.user = {
    id: decoded.userId,
    username: decoded.username,
    email: decoded.email
  };

  next();
}

/**
 * 可选认证中间件
 * 有 Token 就验证，没有也放行
 */
function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    req.user = null;
    return next();
  }

  const parts = authHeader.split(' ');
  if (parts.length === 2 && parts[0] === 'Bearer') {
    const decoded = verifyAccessToken(parts[1]);
    if (decoded) {
      req.user = {
        id: decoded.userId,
        username: decoded.username,
        email: decoded.email
      };
    }
  }

  next();
}

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  authenticate,
  optionalAuth
};
