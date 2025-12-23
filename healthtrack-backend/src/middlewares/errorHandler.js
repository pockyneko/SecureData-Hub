/**
 * 错误处理中间件
 */

/**
 * 404 处理
 */
function notFoundHandler(req, res, next) {
  res.status(404).json({
    success: false,
    code: 'NOT_FOUND',
    message: `接口不存在: ${req.method} ${req.path}`
  });
}

/**
 * 全局错误处理
 */
function errorHandler(err, req, res, next) {
  console.error('服务器错误:', err);

  // 数据库错误
  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({
      success: false,
      code: 'DUPLICATE_ENTRY',
      message: '数据已存在'
    });
  }

  // JWT 错误
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      code: 'TOKEN_INVALID',
      message: '无效的认证令牌'
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      code: 'TOKEN_EXPIRED',
      message: '认证令牌已过期'
    });
  }

  // 默认服务器错误
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    code: err.code || 'INTERNAL_ERROR',
    message: process.env.NODE_ENV === 'production' 
      ? '服务器内部错误' 
      : err.message
  });
}

/**
 * 异步处理包装器
 */
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

module.exports = {
  notFoundHandler,
  errorHandler,
  asyncHandler
};
