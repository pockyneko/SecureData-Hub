/// API 常量配置
class ApiConstants {
  // 基础URL - 根据实际部署修改
  static const String baseUrl = 'http://localhost:3000/api';
  
  // 认证相关
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authProfile = '/auth/profile';
  static const String authPassword = '/auth/password';
  
  // 健康数据相关
  static const String healthRecords = '/health/records';
  static const String healthRecordsBatch = '/health/records/batch';
  static const String healthAnalysis = '/health/analysis';
  static const String healthTrends = '/health/trends';
  static const String healthToday = '/health/today';
  static const String healthGoals = '/health/goals';
  static const String healthMockData = '/health/mock-data';
  
  // 个性化健康档案相关
  static const String healthProfile = '/health-profile';
  static const String healthProfileStandards = '/health-profile/standards';
  static const String healthProfileAnalysis = '/health-profile/analysis/personalized';
  static const String healthProfileDoctorNotes = '/health-profile/doctor-notes';
  
  // 公开服务
  static const String publicTips = '/public/tips';
  static const String publicTipsCategories = '/public/tips/categories';
  static const String publicExercises = '/public/exercises/recommendations';
  static const String publicExerciseWeatherTypes = '/public/exercises/weather-types';
  static const String publicDailyTip = '/public/daily-tip';
  
  // 超时设置
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
