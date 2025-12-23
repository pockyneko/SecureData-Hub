/**
 * 请求验证中间件
 * 使用 express-validator 进行输入验证
 */

const { body, query, param, validationResult } = require('express-validator');

/**
 * 处理验证结果
 */
const handleValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      code: 'VALIDATION_ERROR',
      message: '请求参数验证失败',
      errors: errors.array().map(err => ({
        field: err.path,
        message: err.msg
      }))
    });
  }
  next();
};

/**
 * 用户注册验证规则
 */
const registerValidation = [
  body('username')
    .trim()
    .isLength({ min: 3, max: 20 })
    .withMessage('用户名长度需在 3-20 字符之间')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('用户名只能包含字母、数字和下划线'),
  body('email')
    .trim()
    .isEmail()
    .withMessage('请输入有效的邮箱地址')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6, max: 50 })
    .withMessage('密码长度需在 6-50 字符之间'),
  body('nickname')
    .optional()
    .trim()
    .isLength({ max: 30 })
    .withMessage('昵称长度不能超过 30 字符'),
  body('height')
    .optional()
    .isFloat({ min: 50, max: 250 })
    .withMessage('身高需在 50-250 厘米之间'),
  body('gender')
    .optional()
    .isIn(['male', 'female', 'other'])
    .withMessage('性别值无效'),
  body('birthday')
    .optional()
    .isISO8601()
    .withMessage('生日格式无效'),
  handleValidation
];

/**
 * 用户登录验证规则
 */
const loginValidation = [
  body('identifier')
    .trim()
    .notEmpty()
    .withMessage('请输入用户名或邮箱'),
  body('password')
    .notEmpty()
    .withMessage('请输入密码'),
  handleValidation
];

/**
 * 健康记录创建验证规则
 */
const healthRecordValidation = [
  body('type')
    .isIn(['weight', 'steps', 'blood_pressure_sys', 'blood_pressure_dia', 'heart_rate', 'sleep', 'water', 'calories'])
    .withMessage('数据类型无效'),
  body('value')
    .isFloat({ min: 0 })
    .withMessage('数值必须为非负数'),
  body('note')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('备注长度不能超过 500 字符'),
  body('recordDate')
    .optional()
    .isISO8601()
    .withMessage('日期格式无效'),
  handleValidation
];

/**
 * 健康记录查询验证规则
 */
const healthRecordQueryValidation = [
  query('type')
    .optional()
    .isIn(['weight', 'steps', 'blood_pressure_sys', 'blood_pressure_dia', 'heart_rate', 'sleep', 'water', 'calories'])
    .withMessage('数据类型无效'),
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('开始日期格式无效'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('结束日期格式无效'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 500 })
    .withMessage('limit 需在 1-500 之间'),
  query('offset')
    .optional()
    .isInt({ min: 0 })
    .withMessage('offset 需为非负整数'),
  handleValidation
];

/**
 * 用户目标验证规则
 */
const userGoalValidation = [
  body('stepsGoal')
    .optional()
    .isInt({ min: 1000, max: 100000 })
    .withMessage('步数目标需在 1000-100000 之间'),
  body('waterGoal')
    .optional()
    .isInt({ min: 500, max: 10000 })
    .withMessage('饮水目标需在 500-10000 毫升之间'),
  body('sleepGoal')
    .optional()
    .isFloat({ min: 1, max: 24 })
    .withMessage('睡眠目标需在 1-24 小时之间'),
  body('caloriesGoal')
    .optional()
    .isInt({ min: 500, max: 10000 })
    .withMessage('卡路里目标需在 500-10000 之间'),
  body('weightGoal')
    .optional()
    .isFloat({ min: 20, max: 300 })
    .withMessage('体重目标需在 20-300 公斤之间'),
  handleValidation
];

/**
 * ID 参数验证
 */
const idParamValidation = [
  param('id')
    .isUUID()
    .withMessage('ID 格式无效'),
  handleValidation
];

/**
 * 密码修改验证规则
 */
const passwordUpdateValidation = [
  body('oldPassword')
    .notEmpty()
    .withMessage('请输入原密码'),
  body('newPassword')
    .isLength({ min: 6, max: 50 })
    .withMessage('新密码长度需在 6-50 字符之间'),
  handleValidation
];

/**
 * 用户信息更新验证规则
 */
const profileUpdateValidation = [
  body('nickname')
    .optional()
    .trim()
    .isLength({ max: 30 })
    .withMessage('昵称长度不能超过 30 字符'),
  body('height')
    .optional()
    .isFloat({ min: 50, max: 250 })
    .withMessage('身高需在 50-250 厘米之间'),
  body('gender')
    .optional()
    .isIn(['male', 'female', 'other'])
    .withMessage('性别值无效'),
  body('birthday')
    .optional()
    .isISO8601()
    .withMessage('生日格式无效'),
  handleValidation
];

module.exports = {
  registerValidation,
  loginValidation,
  healthRecordValidation,
  healthRecordQueryValidation,
  userGoalValidation,
  idParamValidation,
  passwordUpdateValidation,
  profileUpdateValidation,
  handleValidation
};
