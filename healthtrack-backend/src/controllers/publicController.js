/**
 * 公开服务控制器
 * 无需认证即可访问的接口
 */

const { HealthTipModel, ExerciseAdviceModel } = require('../models');

/**
 * 获取健康百科列表
 * GET /api/public/tips
 */
async function getHealthTips(req, res) {
  const { category, limit = 50, offset = 0 } = req.query;

  const tips = await HealthTipModel.findAll({
    category,
    limit: parseInt(limit),
    offset: parseInt(offset)
  });

  res.json({
    success: true,
    data: {
      tips: tips.map(t => ({
        id: t.id,
        title: t.title,
        content: t.content,
        category: t.category,
        imageUrl: t.image_url,
        createdAt: t.created_at
      }))
    }
  });
}

/**
 * 获取健康百科分类
 * GET /api/public/tips/categories
 */
async function getTipCategories(req, res) {
  const categories = await HealthTipModel.getCategories();

  res.json({
    success: true,
    data: categories.map(c => c.category)
  });
}

/**
 * 获取健康百科详情
 * GET /api/public/tips/:id
 */
async function getHealthTipById(req, res) {
  const { id } = req.params;
  const tip = await HealthTipModel.findById(id);

  if (!tip) {
    return res.status(404).json({
      success: false,
      code: 'NOT_FOUND',
      message: '内容不存在'
    });
  }

  res.json({
    success: true,
    data: {
      id: tip.id,
      title: tip.title,
      content: tip.content,
      category: tip.category,
      imageUrl: tip.image_url,
      createdAt: tip.created_at
    }
  });
}

/**
 * 获取运动建议列表
 * GET /api/public/exercises
 */
async function getExerciseAdvice(req, res) {
  const { weather, timeSlot, intensity, limit = 20, offset = 0 } = req.query;

  const advice = await ExerciseAdviceModel.findAll({
    weather,
    timeSlot,
    intensity,
    limit: parseInt(limit),
    offset: parseInt(offset)
  });

  res.json({
    success: true,
    data: {
      exercises: advice.map(a => ({
        id: a.id,
        name: a.name,
        description: a.description,
        weather: a.weather,
        timeSlot: a.time_slot,
        intensity: a.intensity,
        duration: a.duration,
        caloriesBurned: a.calories_burned,
        imageUrl: a.image_url
      }))
    }
  });
}

/**
 * 获取运动推荐
 * GET /api/public/exercises/recommendations
 */
async function getExerciseRecommendations(req, res) {
  const { weather = 'sunny', timeSlot = 'morning', limit = 5 } = req.query;

  const recommendations = await ExerciseAdviceModel.getRecommendations({
    weather,
    timeSlot,
    limit: parseInt(limit)
  });

  // 获取当前时间段的描述
  let timeDescription;
  switch (timeSlot) {
    case 'morning': timeDescription = '早晨'; break;
    case 'afternoon': timeDescription = '下午'; break;
    case 'evening': timeDescription = '傍晚'; break;
    case 'night': timeDescription = '夜间'; break;
    default: timeDescription = '全天';
  }

  let weatherDescription;
  switch (weather) {
    case 'sunny': weatherDescription = '晴天'; break;
    case 'cloudy': weatherDescription = '多云'; break;
    case 'rainy': weatherDescription = '雨天'; break;
    case 'snowy': weatherDescription = '雪天'; break;
    case 'hot': weatherDescription = '炎热'; break;
    case 'cold': weatherDescription = '寒冷'; break;
    default: weatherDescription = '普通';
  }

  res.json({
    success: true,
    data: {
      conditions: {
        weather: weatherDescription,
        timeSlot: timeDescription
      },
      message: `根据当前${weatherDescription}${timeDescription}为您推荐以下运动：`,
      recommendations: recommendations.map(r => ({
        id: r.id,
        name: r.name,
        description: r.description,
        intensity: r.intensity,
        duration: r.duration,
        caloriesBurned: r.calories_burned,
        imageUrl: r.image_url
      }))
    }
  });
}

/**
 * 获取天气类型列表
 * GET /api/public/exercises/weather-types
 */
async function getWeatherTypes(req, res) {
  const types = await ExerciseAdviceModel.getWeatherTypes();
  
  const weatherMap = {
    'all': '全部',
    'sunny': '晴天',
    'cloudy': '多云',
    'rainy': '雨天',
    'snowy': '雪天',
    'hot': '炎热',
    'cold': '寒冷'
  };

  res.json({
    success: true,
    data: types.map(t => ({
      value: t.weather,
      label: weatherMap[t.weather] || t.weather
    }))
  });
}

/**
 * 获取健康小贴士（每日一条）
 * GET /api/public/daily-tip
 */
async function getDailyTip(req, res) {
  const tips = await HealthTipModel.findAll({ limit: 100 });
  
  if (tips.length === 0) {
    return res.json({
      success: true,
      data: {
        tip: '保持健康的生活方式，每天运动30分钟！'
      }
    });
  }

  // 根据日期选择一条
  const today = new Date();
  const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / (1000 * 60 * 60 * 24));
  const selectedTip = tips[dayOfYear % tips.length];

  res.json({
    success: true,
    data: {
      id: selectedTip.id,
      title: selectedTip.title,
      content: selectedTip.content,
      category: selectedTip.category
    }
  });
}

module.exports = {
  getHealthTips,
  getTipCategories,
  getHealthTipById,
  getExerciseAdvice,
  getExerciseRecommendations,
  getWeatherTypes,
  getDailyTip
};
