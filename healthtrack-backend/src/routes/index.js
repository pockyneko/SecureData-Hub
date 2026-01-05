/**
 * 路由统一导出
 */

const authRoutes = require('./authRoutes');
const healthRoutes = require('./healthRoutes');
const publicRoutes = require('./publicRoutes');
const personalizedHealthRoutes = require('./personalizedHealthRoutes');

module.exports = {
  authRoutes,
  healthRoutes,
  publicRoutes,
  personalizedHealthRoutes
};
