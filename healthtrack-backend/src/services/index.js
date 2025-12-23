/**
 * 服务层统一导出
 */

const mockDataService = require('./mockDataService');
const healthAnalysisService = require('./healthAnalysisService');

module.exports = {
  ...mockDataService,
  ...healthAnalysisService
};
