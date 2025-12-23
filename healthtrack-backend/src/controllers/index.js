/**
 * 控制器统一导出
 */

const authController = require('./authController');
const healthController = require('./healthController');
const publicController = require('./publicController');

module.exports = {
  authController,
  healthController,
  publicController
};
