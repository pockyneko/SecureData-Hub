/**
 * 个性化健康路由
 * 提供个性化健康档案管理和分析接口
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');

const { authenticate } = require('../middlewares');
const { UserHealthProfileModel } = require('../models');
const { getPersonalizedHealthAnalysis } = require('../services');

/**
 * 获取用户的个性化健康标准
 * GET /health-profile/standards
 */
router.get('/standards', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    const standards = await UserHealthProfileModel.getPersonalizedStandards(userId);

    res.json({
      success: true,
      data: standards || {
        message: '个性化标准还未生成，请先完善健康档案信息'
      }
    });
  } catch (error) {
    console.error('获取个性化标准失败:', error);
    res.status(500).json({
      success: false,
      message: '获取个性化标准失败',
      error: error.message
    });
  }
});

/**
 * 获取个性化健康分析报告
 * GET /health-profile/analysis/personalized
 */
router.get('/analysis/personalized', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    const analysis = await getPersonalizedHealthAnalysis(userId);

    res.json({
      success: true,
      data: analysis
    });
  } catch (error) {
    console.error('获取个性化健康分析失败:', error);
    res.status(500).json({
      success: false,
      message: '获取个性化健康分析失败',
      error: error.message
    });
  }
});

/**
 * 更新医生建议
 * PUT /health-profile/doctor-notes
 */
router.put(
  '/doctor-notes',
  authenticate,
  [body('doctorNotes').isString().trim()],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const userId = req.user.id;
      const profile = await UserHealthProfileModel.update(userId, {
        doctorNotes: req.body.doctorNotes
      });

      res.json({
        success: true,
        message: '医生建议更新成功',
        data: profile
      });
    } catch (error) {
      console.error('更新医生建议失败:', error);
      res.status(500).json({
        success: false,
        message: '更新医生建议失败',
        error: error.message
      });
    }
  }
);

/**
 * 获取用户的个性化健康档案
 * GET /health-profile
 */
router.get('/', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    const profile = await UserHealthProfileModel.findByUserId(userId);

    res.json({
      success: true,
      data: profile || {
        message: '还未创建个性化健康档案，请先完善信息'
      }
    });
  } catch (error) {
    console.error('获取健康档案失败:', error);
    res.status(500).json({
      success: false,
      message: '获取健康档案失败',
      error: error.message
    });
  }
});

/**
 * 创建或更新用户的个性化健康档案
 * POST /health-profile
 */
router.post(
  '/',
  authenticate,
  [
    body('ageGroup').isIn(['child', 'teen', 'adult', 'middle_age', 'senior']),
    body('activityLevel').optional().isIn(['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active']),
    body('healthCondition').optional().isIn(['excellent', 'good', 'fair', 'poor']),
    body('hasCardiovascularIssues').optional().isBoolean(),
    body('hasDiabetes').optional().isBoolean(),
    body('hasJointIssues').optional().isBoolean(),
    body('isPregnant').optional().isBoolean(),
    body('isRecovering').optional().isBoolean(),
    body('personalizedStepsGoal').optional().isInt({ min: 0, max: 50000 }),
    body('personalizedHeartRateMin').optional().isInt({ min: 0, max: 200 }),
    body('personalizedHeartRateMax').optional().isInt({ min: 0, max: 220 }),
    body('personalizedSleepGoal').optional().isFloat({ min: 0, max: 15 }),
    body('personalizedWaterGoal').optional().isInt({ min: 0, max: 10000 })
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const userId = req.user.id;
      const existing = await UserHealthProfileModel.findByUserId(userId);

      let profile;
      if (existing) {
        profile = await UserHealthProfileModel.update(userId, req.body);
      } else {
        profile = await UserHealthProfileModel.create(userId, req.body);
      }

      res.json({
        success: true,
        message: existing ? '健康档案更新成功' : '健康档案创建成功',
        data: profile
      });
    } catch (error) {
      console.error('创建/更新健康档案失败:', error);
      res.status(500).json({
        success: false,
        message: '创建/更新健康档案失败',
        error: error.message
      });
    }
  }
);

/**
 * 删除用户的个性化健康档案
 * DELETE /health-profile
 */
router.delete('/', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    await UserHealthProfileModel.deleteByUserId(userId);

    res.json({
      success: true,
      message: '健康档案删除成功'
    });
  } catch (error) {
    console.error('删除健康档案失败:', error);
    res.status(500).json({
      success: false,
      message: '删除健康档案失败',
      error: error.message
    });
  }
});

module.exports = router;
