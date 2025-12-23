/**
 * 健康数据控制器
 * 处理健康记录的 CRUD 操作
 * 【核心】所有操作都基于 JWT 解析出的 userId，实现水平权限保护
 */

const { HealthRecordModel, UserGoalModel } = require('../models');
const { getHealthAnalysis, getTrendData } = require('../services/healthAnalysisService');
const { generateMockDataForUser, generateDemoData } = require('../services/mockDataService');
const moment = require('moment');

/**
 * 获取健康记录列表
 * GET /api/health/records
 * 【水平权限保护】只查询当前用户的数据
 */
async function getRecords(req, res) {
  const userId = req.user.id; // 从 JWT 获取，非请求参数
  const { type, startDate, endDate, limit = 100, offset = 0 } = req.query;

  const records = await HealthRecordModel.findByUserId(userId, {
    type,
    startDate,
    endDate,
    limit: parseInt(limit),
    offset: parseInt(offset)
  });

  const total = await HealthRecordModel.countByUserId(userId);

  res.json({
    success: true,
    data: {
      records: records.map(r => ({
        id: r.id,
        type: r.type,
        value: r.value,
        note: r.note,
        recordDate: moment(r.record_date).format('YYYY-MM-DD'),
        createdAt: r.created_at
      })),
      pagination: {
        total,
        limit: parseInt(limit),
        offset: parseInt(offset)
      }
    }
  });
}

/**
 * 创建健康记录
 * POST /api/health/records
 */
async function createRecord(req, res) {
  const userId = req.user.id;
  const { type, value, note, recordDate } = req.body;

  const record = await HealthRecordModel.create({
    userId,
    type,
    value,
    note,
    recordDate
  });

  res.status(201).json({
    success: true,
    message: '记录创建成功',
    data: record
  });
}

/**
 * 批量创建健康记录
 * POST /api/health/records/batch
 */
async function createRecordsBatch(req, res) {
  const userId = req.user.id;
  const { records } = req.body;

  if (!Array.isArray(records) || records.length === 0) {
    return res.status(400).json({
      success: false,
      code: 'INVALID_DATA',
      message: '请提供有效的记录数组'
    });
  }

  // 为所有记录添加 userId
  const recordsWithUser = records.map(r => ({
    ...r,
    userId
  }));

  const insertedCount = await HealthRecordModel.createMany(recordsWithUser);

  res.status(201).json({
    success: true,
    message: `成功创建 ${insertedCount} 条记录`,
    data: { insertedCount }
  });
}

/**
 * 更新健康记录
 * PUT /api/health/records/:id
 * 【水平权限保护】只能更新自己的记录
 */
async function updateRecord(req, res) {
  const userId = req.user.id;
  const { id } = req.params;
  const { value, note, recordDate } = req.body;

  const updated = await HealthRecordModel.update(id, userId, {
    value,
    note,
    recordDate
  });

  if (!updated) {
    return res.status(404).json({
      success: false,
      code: 'NOT_FOUND',
      message: '记录不存在或无权修改'
    });
  }

  res.json({
    success: true,
    message: '记录更新成功'
  });
}

/**
 * 删除健康记录
 * DELETE /api/health/records/:id
 * 【水平权限保护】只能删除自己的记录
 */
async function deleteRecord(req, res) {
  const userId = req.user.id;
  const { id } = req.params;

  const deleted = await HealthRecordModel.delete(id, userId);

  if (!deleted) {
    return res.status(404).json({
      success: false,
      code: 'NOT_FOUND',
      message: '记录不存在或无权删除'
    });
  }

  res.json({
    success: true,
    message: '记录删除成功'
  });
}

/**
 * 获取健康分析报告
 * GET /api/health/analysis
 */
async function getAnalysis(req, res) {
  const userId = req.user.id;

  const analysis = await getHealthAnalysis(userId);

  res.json({
    success: true,
    data: analysis
  });
}

/**
 * 获取趋势数据
 * GET /api/health/trends/:type
 */
async function getTrends(req, res) {
  const userId = req.user.id;
  const { type } = req.params;
  const { period = 'week' } = req.query;

  const validTypes = ['weight', 'steps', 'heart_rate', 'blood_pressure_sys', 'blood_pressure_dia', 'sleep', 'water', 'calories'];
  if (!validTypes.includes(type)) {
    return res.status(400).json({
      success: false,
      code: 'INVALID_TYPE',
      message: '无效的数据类型'
    });
  }

  const trendData = await getTrendData(userId, type, period);

  res.json({
    success: true,
    data: trendData
  });
}

/**
 * 获取今日概览
 * GET /api/health/today
 */
async function getTodaySummary(req, res) {
  const userId = req.user.id;
  const today = moment().format('YYYY-MM-DD');

  const records = await HealthRecordModel.findByUserId(userId, {
    startDate: today,
    endDate: today
  });

  // 获取用户目标
  const goals = await UserGoalModel.findByUserIdWithDefaults(userId);

  // 按类型汇总
  const summary = {};
  records.forEach(r => {
    if (!summary[r.type]) {
      summary[r.type] = {
        type: r.type,
        value: 0,
        count: 0,
        latest: null
      };
    }
    summary[r.type].count++;
    summary[r.type].latest = r.value;
    
    // 步数和饮水量需要累加
    if (r.type === 'steps' || r.type === 'water' || r.type === 'calories') {
      summary[r.type].value += r.value;
    } else {
      summary[r.type].value = r.value; // 其他类型取最新值
    }
  });

  // 计算目标完成度
  const goalProgress = {
    steps: {
      current: summary.steps?.value || 0,
      goal: goals.stepsGoal,
      percentage: Math.min(100, Math.round(((summary.steps?.value || 0) / goals.stepsGoal) * 100))
    },
    water: {
      current: summary.water?.value || 0,
      goal: goals.waterGoal,
      percentage: Math.min(100, Math.round(((summary.water?.value || 0) / goals.waterGoal) * 100))
    },
    sleep: {
      current: summary.sleep?.value || 0,
      goal: goals.sleepGoal,
      percentage: Math.min(100, Math.round(((summary.sleep?.value || 0) / goals.sleepGoal) * 100))
    }
  };

  res.json({
    success: true,
    data: {
      date: today,
      summary,
      goals,
      goalProgress
    }
  });
}

/**
 * 获取/更新用户目标
 * GET/PUT /api/health/goals
 */
async function getGoals(req, res) {
  const userId = req.user.id;
  const goals = await UserGoalModel.findByUserIdWithDefaults(userId);

  res.json({
    success: true,
    data: goals
  });
}

async function updateGoals(req, res) {
  const userId = req.user.id;
  const { stepsGoal, waterGoal, sleepGoal, caloriesGoal, weightGoal } = req.body;

  const goals = await UserGoalModel.upsert(userId, {
    stepsGoal,
    waterGoal,
    sleepGoal,
    caloriesGoal,
    weightGoal
  });

  res.json({
    success: true,
    message: '目标更新成功',
    data: {
      stepsGoal: goals.steps_goal,
      waterGoal: goals.water_goal,
      sleepGoal: goals.sleep_goal,
      caloriesGoal: goals.calories_goal,
      weightGoal: goals.weight_goal
    }
  });
}

/**
 * 生成模拟数据
 * POST /api/health/mock-data
 */
async function generateMockData(req, res) {
  const userId = req.user.id;
  const { days = 30, demoMode = false } = req.body;

  let result;
  if (demoMode) {
    result = await generateDemoData(userId);
  } else {
    result = await generateMockDataForUser(userId, { days });
  }

  res.json({
    success: true,
    message: result.message,
    data: result
  });
}

module.exports = {
  getRecords,
  createRecord,
  createRecordsBatch,
  updateRecord,
  deleteRecord,
  getAnalysis,
  getTrends,
  getTodaySummary,
  getGoals,
  updateGoals,
  generateMockData
};
