/**
 * 服务层统一导出
 */

const mockDataService = require('./mockDataService');
const healthAnalysisService = require('./healthAnalysisService');
const personalizedHealthAnalysisService = require('./personalizedHealthAnalysisService');

module.exports = {
  ...mockDataService,
  ...healthAnalysisService,
  ...personalizedHealthAnalysisService
};
