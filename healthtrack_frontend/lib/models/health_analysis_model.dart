import '../core/utils/parse_utils.dart';

/// 健康分析报告模型
class HealthAnalysis {
  final AnalysisUser user;
  final CurrentStatus currentStatus;
  final BmiAnalysis? bmiAnalysis;
  final Statistics statistics;
  final HealthGoals goals;
  final int healthScore;
  final List<Recommendation> recommendations;
  final DateTime analyzedAt;

  HealthAnalysis({
    required this.user,
    required this.currentStatus,
    this.bmiAnalysis,
    required this.statistics,
    required this.goals,
    required this.healthScore,
    required this.recommendations,
    required this.analyzedAt,
  });

  factory HealthAnalysis.fromJson(Map<String, dynamic> json) {
    return HealthAnalysis(
      user: AnalysisUser.fromJson(json['user'] ?? {}),
      currentStatus: CurrentStatus.fromJson(json['currentStatus'] ?? {}),
      bmiAnalysis: json['bmiAnalysis'] != null 
          ? BmiAnalysis.fromJson(json['bmiAnalysis'])
          : null,
      statistics: Statistics.fromJson(json['statistics'] ?? {}),
      goals: HealthGoals.fromJson(json['goals'] ?? {}),
      healthScore: json['healthScore'] ?? 0,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => Recommendation.fromJson(e))
          .toList() ?? [],
      analyzedAt: DateTime.parse(json['analyzedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// 分析用户信息
class AnalysisUser {
  final String? nickname;
  final double? height;
  final String? gender;

  AnalysisUser({
    this.nickname,
    this.height,
    this.gender,
  });

  factory AnalysisUser.fromJson(Map<String, dynamic> json) {
    return AnalysisUser(
      nickname: json['nickname'],
      height: json['height'] != null ? ParseUtils.toDouble(json['height']) : null,
      gender: json['gender'],
    );
  }
}

/// 当前状态
class CurrentStatus {
  final double? weight;
  final int? steps;
  final int? heartRate;
  final String? bloodPressure;
  final double? sleep;
  final int? water;
  final int? calories;

  CurrentStatus({
    this.weight,
    this.steps,
    this.heartRate,
    this.bloodPressure,
    this.sleep,
    this.water,
    this.calories,
  });

  factory CurrentStatus.fromJson(Map<String, dynamic> json) {
    return CurrentStatus(
      weight: json['weight'] != null ? ParseUtils.toDouble(json['weight']) : null,
      steps: json['steps'] != null ? ParseUtils.toInt(json['steps']) : null,
      heartRate: json['heartRate'] != null ? ParseUtils.toInt(json['heartRate']) : null,
      bloodPressure: json['bloodPressure'],
      sleep: json['sleep'] != null ? ParseUtils.toDouble(json['sleep']) : null,
      water: json['water'] != null ? ParseUtils.toInt(json['water']) : null,
      calories: json['calories'] != null ? ParseUtils.toInt(json['calories']) : null,
    );
  }
}

/// BMI分析
class BmiAnalysis {
  final double bmi;
  final double min;
  final double max;
  final String label;
  final String? advice;

  BmiAnalysis({
    required this.bmi,
    required this.min,
    required this.max,
    required this.label,
    this.advice,
  });

  factory BmiAnalysis.fromJson(Map<String, dynamic> json) {
    return BmiAnalysis(
      bmi: ParseUtils.toDouble(json['bmi']),
      min: ParseUtils.toDouble(json['min']),
      max: ParseUtils.toDouble(json['max']),
      label: json['label'] ?? '',
      advice: json['advice'],
    );
  }
}

/// 统计数据
class Statistics {
  final WeeklyStats? weekly;
  final MonthlyStats? monthly;

  Statistics({
    this.weekly,
    this.monthly,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      weekly: json['weekly'] != null 
          ? WeeklyStats.fromJson(json['weekly'])
          : null,
      monthly: json['monthly'] != null 
          ? MonthlyStats.fromJson(json['monthly'])
          : null,
    );
  }
}

/// 周统计
class WeeklyStats {
  final double avgSteps;
  final int totalSteps;
  final double avgWeight;

  WeeklyStats({
    required this.avgSteps,
    required this.totalSteps,
    required this.avgWeight,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      avgSteps: ParseUtils.toDouble(json['avgSteps']),
      totalSteps: ParseUtils.toInt(json['totalSteps']),
      avgWeight: ParseUtils.toDouble(json['avgWeight']),
    );
  }
}

/// 月统计
class MonthlyStats {
  final double avgSteps;
  final int totalSteps;
  final double avgWeight;
  final double? weightChange;

  MonthlyStats({
    required this.avgSteps,
    required this.totalSteps,
    required this.avgWeight,
    this.weightChange,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      avgSteps: ParseUtils.toDouble(json['avgSteps']),
      totalSteps: ParseUtils.toInt(json['totalSteps']),
      avgWeight: ParseUtils.toDouble(json['avgWeight']),
      weightChange: json['weightChange'] != null ? ParseUtils.toDouble(json['weightChange']) : null,
    );
  }
}

/// 健康目标
class HealthGoals {
  final int stepsGoal;
  final int waterGoal;
  final double sleepGoal;
  final int caloriesGoal;
  final double? weightGoal;

  HealthGoals({
    required this.stepsGoal,
    required this.waterGoal,
    required this.sleepGoal,
    required this.caloriesGoal,
    this.weightGoal,
  });

  factory HealthGoals.fromJson(Map<String, dynamic> json) {
    return HealthGoals(
      stepsGoal: ParseUtils.toInt(json['stepsGoal'], 10000),
      waterGoal: ParseUtils.toInt(json['waterGoal'], 2500),
      sleepGoal: ParseUtils.toDouble(json['sleepGoal'], 8.0),
      caloriesGoal: ParseUtils.toInt(json['caloriesGoal'], 2200),
      weightGoal: json['weightGoal'] != null ? ParseUtils.toDouble(json['weightGoal']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepsGoal': stepsGoal,
      'waterGoal': waterGoal,
      'sleepGoal': sleepGoal,
      'caloriesGoal': caloriesGoal,
      if (weightGoal != null) 'weightGoal': weightGoal,
    };
  }
}

/// 健康建议
class Recommendation {
  final String category;
  final String priority;
  final String advice;

  Recommendation({
    required this.category,
    required this.priority,
    required this.advice,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'low',
      advice: json['advice'] ?? '',
    );
  }
}
