/**
 * 中间件统一导出
 */

const authMiddleware = require('./auth');
const validator = require('./validator');
const errorHandler = require('./errorHandler');

module.exports = {
  ...authMiddleware,
  ...validator,
  ...errorHandler
};
