/**
 * 公开服务路由
 * 无需认证即可访问
 */

const express = require('express');
const router = express.Router();
const { publicController } = require('../controllers');
const { asyncHandler, idParamValidation } = require('../middlewares');

/**
 * @route   GET /api/public/tips
 * @desc    获取健康百科列表
 * @access  Public
 */
router.get('/tips', asyncHandler(publicController.getHealthTips));

/**
 * @route   GET /api/public/tips/categories
 * @desc    获取健康百科分类
 * @access  Public
 */
router.get('/tips/categories', asyncHandler(publicController.getTipCategories));

/**
 * @route   GET /api/public/tips/:id
 * @desc    获取健康百科详情
 * @access  Public
 */
router.get('/tips/:id', asyncHandler(publicController.getHealthTipById));

/**
 * @route   GET /api/public/exercises
 * @desc    获取运动建议列表
 * @access  Public
 */
router.get('/exercises', asyncHandler(publicController.getExerciseAdvice));

/**
 * @route   GET /api/public/exercises/recommendations
 * @desc    获取运动推荐
 * @access  Public
 */
router.get('/exercises/recommendations', asyncHandler(publicController.getExerciseRecommendations));

/**
 * @route   GET /api/public/exercises/weather-types
 * @desc    获取天气类型列表
 * @access  Public
 */
router.get('/exercises/weather-types', asyncHandler(publicController.getWeatherTypes));

/**
 * @route   GET /api/public/daily-tip
 * @desc    获取每日健康小贴士
 * @access  Public
 */
router.get('/daily-tip', asyncHandler(publicController.getDailyTip));

module.exports = router;
