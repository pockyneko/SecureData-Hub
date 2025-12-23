/**
 * 路由统一导出
 */

const authRoutes = require('./authRoutes');
const healthRoutes = require('./healthRoutes');
const publicRoutes = require('./publicRoutes');

module.exports = {
  authRoutes,
  healthRoutes,
  publicRoutes
};
