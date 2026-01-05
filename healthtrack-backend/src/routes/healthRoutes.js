/**
 * 健康数据路由
 */

const express = require('express');
const router = express.Router();
const { healthController } = require('../controllers');
const { 
  authenticate, 
  healthRecordValidation,
  healthRecordQueryValidation,
  userGoalValidation,
  idParamValidation,
  asyncHandler 
} = require('../middlewares');

// 所有健康数据接口都需要认证
router.use(authenticate);

/**
 * @route   GET /api/health/records
 * @desc    获取健康记录列表
 * @access  Private
 */
router.get('/records', healthRecordQueryValidation, asyncHandler(healthController.getRecords));

/**
 * @route   POST /api/health/records
 * @desc    创建健康记录
 * @access  Private
 */
router.post('/records', healthRecordValidation, asyncHandler(healthController.createRecord));

/**
 * @route   POST /api/health/records/batch
 * @desc    批量创建健康记录
 * @access  Private
 */
router.post('/records/batch', asyncHandler(healthController.createRecordsBatch));

/**
 * @route   PUT /api/health/records/:id
 * @desc    更新健康记录
 * @access  Private
 */
router.put('/records/:id', idParamValidation, asyncHandler(healthController.updateRecord));

/**
 * @route   DELETE /api/health/records/:id
 * @desc    删除健康记录
 * @access  Private
 */
router.delete('/records/:id', idParamValidation, asyncHandler(healthController.deleteRecord));

/**
 * @route   GET /api/health/analysis
 * @desc    获取健康分析报告
 * @access  Private
 */
router.get('/analysis', asyncHandler(healthController.getAnalysis));

/**
 * @route   GET /api/health/trends/:type
 * @desc    获取趋势数据
 * @access  Private
 */
router.get('/trends/:type', asyncHandler(healthController.getTrends));

/**
 * @route   GET /api/health/today
 * @desc    获取今日概览
 * @access  Private
 */
router.get('/today', asyncHandler(healthController.getTodaySummary));

/**
 * @route   GET /api/health/goals
 * @desc    获取用户目标
 * @access  Private
 */
router.get('/goals', asyncHandler(healthController.getGoals));

/**
 * @route   PUT /api/health/goals
 * @desc    更新用户目标
 * @access  Private
 */
router.put('/goals', userGoalValidation, asyncHandler(healthController.updateGoals));

/**
 * @route   POST /api/health/mock-data
 * @desc    生成模拟数据（演示用）
 * @access  Private
 */
router.post('/mock-data', asyncHandler(healthController.generateMockData));

module.exports = router;
