/**
 * 认证路由
 */

const express = require('express');
const router = express.Router();
const { authController } = require('../controllers');
const { 
  authenticate, 
  registerValidation, 
  loginValidation,
  passwordUpdateValidation,
  profileUpdateValidation,
  asyncHandler 
} = require('../middlewares');

/**
 * @route   POST /api/auth/register
 * @desc    用户注册
 * @access  Public
 */
router.post('/register', registerValidation, asyncHandler(authController.register));

/**
 * @route   POST /api/auth/login
 * @desc    用户登录
 * @access  Public
 */
router.post('/login', loginValidation, asyncHandler(authController.login));

/**
 * @route   POST /api/auth/refresh
 * @desc    刷新 Token
 * @access  Public
 */
router.post('/refresh', asyncHandler(authController.refreshToken));

/**
 * @route   GET /api/auth/profile
 * @desc    获取当前用户信息
 * @access  Private
 */
router.get('/profile', authenticate, asyncHandler(authController.getProfile));

/**
 * @route   PUT /api/auth/profile
 * @desc    更新用户信息
 * @access  Private
 */
router.put('/profile', authenticate, profileUpdateValidation, asyncHandler(authController.updateProfile));

/**
 * @route   PUT /api/auth/password
 * @desc    修改密码
 * @access  Private
 */
router.put('/password', authenticate, passwordUpdateValidation, asyncHandler(authController.updatePassword));

module.exports = router;
