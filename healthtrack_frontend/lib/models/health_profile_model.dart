/// 用户健康档案模型

/// 将动态值转换为布尔值（处理 int 0/1 和 bool 类型）
bool _toBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

/// 将动态值安全转换为 double（处理 String、int、num 类型）
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed;
  }
  return null;
}

/// 将动态值安全转换为 int（处理 String、double、num 类型）
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    // 尝试解析为 double 再转 int
    final parsedDouble = double.tryParse(value);
    return parsedDouble?.toInt();
  }
  return null;
}

/// 年龄段枚举
enum AgeGroup {
  child,
  teen,
  adult,
  middleAge,
  senior;

  String get value {
    switch (this) {
      case AgeGroup.child:
        return 'child';
      case AgeGroup.teen:
        return 'teen';
      case AgeGroup.adult:
        return 'adult';
      case AgeGroup.middleAge:
        return 'middle_age';
      case AgeGroup.senior:
        return 'senior';
    }
  }

  String get displayName {
    switch (this) {
      case AgeGroup.child:
        return '儿童 (0-12岁)';
      case AgeGroup.teen:
        return '青少年 (13-18岁)';
      case AgeGroup.adult:
        return '成人 (19-40岁)';
      case AgeGroup.middleAge:
        return '中年 (41-65岁)';
      case AgeGroup.senior:
        return '老年 (65岁以上)';
    }
  }

  static AgeGroup? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'child':
        return AgeGroup.child;
      case 'teen':
        return AgeGroup.teen;
      case 'adult':
        return AgeGroup.adult;
      case 'middle_age':
        return AgeGroup.middleAge;
      case 'senior':
        return AgeGroup.senior;
      default:
        return null;
    }
  }
}

/// 活动水平枚举
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive;

  String get value {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'sedentary';
      case ActivityLevel.lightlyActive:
        return 'lightly_active';
      case ActivityLevel.moderatelyActive:
        return 'moderately_active';
      case ActivityLevel.veryActive:
        return 'very_active';
      case ActivityLevel.extremelyActive:
        return 'extremely_active';
    }
  }

  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return '久坐';
      case ActivityLevel.lightlyActive:
        return '轻度活动';
      case ActivityLevel.moderatelyActive:
        return '中等活动';
      case ActivityLevel.veryActive:
        return '高度活动';
      case ActivityLevel.extremelyActive:
        return '极高活动';
    }
  }

  static ActivityLevel? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'sedentary':
        return ActivityLevel.sedentary;
      case 'lightly_active':
        return ActivityLevel.lightlyActive;
      case 'moderately_active':
        return ActivityLevel.moderatelyActive;
      case 'very_active':
        return ActivityLevel.veryActive;
      case 'extremely_active':
        return ActivityLevel.extremelyActive;
      default:
        return null;
    }
  }
}

/// 健康状态枚举
enum HealthCondition {
  excellent,
  good,
  fair,
  poor;

  String get value {
    switch (this) {
      case HealthCondition.excellent:
        return 'excellent';
      case HealthCondition.good:
        return 'good';
      case HealthCondition.fair:
        return 'fair';
      case HealthCondition.poor:
        return 'poor';
    }
  }

  String get displayName {
    switch (this) {
      case HealthCondition.excellent:
        return '优秀';
      case HealthCondition.good:
        return '良好';
      case HealthCondition.fair:
        return '一般';
      case HealthCondition.poor:
        return '较差';
    }
  }

  static HealthCondition? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'excellent':
        return HealthCondition.excellent;
      case 'good':
        return HealthCondition.good;
      case 'fair':
        return HealthCondition.fair;
      case 'poor':
        return HealthCondition.poor;
      default:
        return null;
    }
  }
}

/// 用户健康档案
class UserHealthProfile {
  final String? id;
  final String? userId;
  final AgeGroup? ageGroup;
  final ActivityLevel? activityLevel;
  final HealthCondition? healthCondition;
  final bool hasCardiovascularIssues;
  final bool hasDiabetes;
  final bool hasJointIssues;
  final bool isPregnant;
  final bool isRecovering;
  final int? personalizedStepsGoal;
  final int? personalizedHeartRateMin;
  final int? personalizedHeartRateMax;
  final double? personalizedSleepGoal;
  final int? personalizedWaterGoal;
  final String? doctorNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserHealthProfile({
    this.id,
    this.userId,
    this.ageGroup,
    this.activityLevel,
    this.healthCondition,
    this.hasCardiovascularIssues = false,
    this.hasDiabetes = false,
    this.hasJointIssues = false,
    this.isPregnant = false,
    this.isRecovering = false,
    this.personalizedStepsGoal,
    this.personalizedHeartRateMin,
    this.personalizedHeartRateMax,
    this.personalizedSleepGoal,
    this.personalizedWaterGoal,
    this.doctorNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory UserHealthProfile.fromJson(Map<String, dynamic> json) {
    return UserHealthProfile(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      ageGroup: AgeGroup.fromString(json['ageGroup'] ?? json['age_group']),
      activityLevel: ActivityLevel.fromString(json['activityLevel'] ?? json['activity_level']),
      healthCondition: HealthCondition.fromString(json['healthCondition'] ?? json['health_condition']),
      hasCardiovascularIssues: _toBool(json['hasCardiovascularIssues'] ?? json['has_cardiovascular_issues']),
      hasDiabetes: _toBool(json['hasDiabetes'] ?? json['has_diabetes']),
      hasJointIssues: _toBool(json['hasJointIssues'] ?? json['has_joint_issues']),
      isPregnant: _toBool(json['isPregnant'] ?? json['is_pregnant']),
      isRecovering: _toBool(json['isRecovering'] ?? json['is_recovering']),
      personalizedStepsGoal: _toInt(json['personalizedStepsGoal'] ?? json['personalized_steps_goal']),
      personalizedHeartRateMin: _toInt(json['personalizedHeartRateMin'] ?? json['personalized_heart_rate_min']),
      personalizedHeartRateMax: _toInt(json['personalizedHeartRateMax'] ?? json['personalized_heart_rate_max']),
      personalizedSleepGoal: _toDouble(json['personalizedSleepGoal'] ?? json['personalized_sleep_goal']),
      personalizedWaterGoal: _toInt(json['personalizedWaterGoal'] ?? json['personalized_water_goal']),
      doctorNotes: json['doctorNotes'] ?? json['doctor_notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) 
          : json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) 
          : json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ageGroup != null) 'ageGroup': ageGroup!.value,
      if (activityLevel != null) 'activityLevel': activityLevel!.value,
      if (healthCondition != null) 'healthCondition': healthCondition!.value,
      'hasCardiovascularIssues': hasCardiovascularIssues,
      'hasDiabetes': hasDiabetes,
      'hasJointIssues': hasJointIssues,
      'isPregnant': isPregnant,
      'isRecovering': isRecovering,
      if (personalizedStepsGoal != null) 'personalizedStepsGoal': personalizedStepsGoal,
      if (personalizedHeartRateMin != null) 'personalizedHeartRateMin': personalizedHeartRateMin,
      if (personalizedHeartRateMax != null) 'personalizedHeartRateMax': personalizedHeartRateMax,
      if (personalizedSleepGoal != null) 'personalizedSleepGoal': personalizedSleepGoal,
      if (personalizedWaterGoal != null) 'personalizedWaterGoal': personalizedWaterGoal,
      if (doctorNotes != null) 'doctorNotes': doctorNotes,
    };
  }

  UserHealthProfile copyWith({
    String? id,
    String? userId,
    AgeGroup? ageGroup,
    ActivityLevel? activityLevel,
    HealthCondition? healthCondition,
    bool? hasCardiovascularIssues,
    bool? hasDiabetes,
    bool? hasJointIssues,
    bool? isPregnant,
    bool? isRecovering,
    int? personalizedStepsGoal,
    int? personalizedHeartRateMin,
    int? personalizedHeartRateMax,
    double? personalizedSleepGoal,
    int? personalizedWaterGoal,
    String? doctorNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserHealthProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ageGroup: ageGroup ?? this.ageGroup,
      activityLevel: activityLevel ?? this.activityLevel,
      healthCondition: healthCondition ?? this.healthCondition,
      hasCardiovascularIssues: hasCardiovascularIssues ?? this.hasCardiovascularIssues,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasJointIssues: hasJointIssues ?? this.hasJointIssues,
      isPregnant: isPregnant ?? this.isPregnant,
      isRecovering: isRecovering ?? this.isRecovering,
      personalizedStepsGoal: personalizedStepsGoal ?? this.personalizedStepsGoal,
      personalizedHeartRateMin: personalizedHeartRateMin ?? this.personalizedHeartRateMin,
      personalizedHeartRateMax: personalizedHeartRateMax ?? this.personalizedHeartRateMax,
      personalizedSleepGoal: personalizedSleepGoal ?? this.personalizedSleepGoal,
      personalizedWaterGoal: personalizedWaterGoal ?? this.personalizedWaterGoal,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 个性化健康标准
class PersonalizedHealthStandards {
  final String? userId;
  final String? username;
  final String? gender;
  final int? age;
  final String? ageGroup;
  final String? activityLevel;
  final String? healthCondition;
  final int? recommendedDailySteps;
  final int? recommendedHeartRateMin;
  final int? recommendedHeartRateMax;
  final double? recommendedSleepHours;
  final int? recommendedWaterMl;
  final double? bmiOptimalMin;
  final double? bmiOptimalMax;
  final int? bloodPressureSystolicNormal;
  final int? bloodPressureDiastolicNormal;
  final String? bloodPressureNormalString;
  final String? doctorNotes;

  PersonalizedHealthStandards({
    this.userId,
    this.username,
    this.gender,
    this.age,
    this.ageGroup,
    this.activityLevel,
    this.healthCondition,
    this.recommendedDailySteps,
    this.recommendedHeartRateMin,
    this.recommendedHeartRateMax,
    this.recommendedSleepHours,
    this.recommendedWaterMl,
    this.bmiOptimalMin,
    this.bmiOptimalMax,
    this.bloodPressureSystolicNormal,
    this.bloodPressureDiastolicNormal,
    this.bloodPressureNormalString,
    this.doctorNotes,
  });

  factory PersonalizedHealthStandards.fromJson(Map<String, dynamic> json) {
    return PersonalizedHealthStandards(
      userId: json['user_id'] ?? json['userId'],
      username: json['username'],
      gender: json['gender'],
      age: json['age'],
      ageGroup: json['age_group'] ?? json['ageGroup'],
      activityLevel: json['activity_level'] ?? json['activityLevel'],
      healthCondition: json['health_condition'] ?? json['healthCondition'],
      recommendedDailySteps: _toInt(json['recommended_daily_steps'] ?? json['recommendedDailySteps']),
      recommendedHeartRateMin: _toInt(json['recommended_heart_rate_min'] ?? json['recommendedHeartRateMin']),
      recommendedHeartRateMax: _toInt(json['recommended_heart_rate_max'] ?? json['recommendedHeartRateMax']),
      recommendedSleepHours: _toDouble(json['recommended_sleep_hours'] ?? json['recommendedSleepHours']),
      recommendedWaterMl: _toInt(json['recommended_water_ml'] ?? json['recommendedWaterMl']),
      bmiOptimalMin: _toDouble(json['bmi_optimal_min'] ?? json['bmiOptimalMin']),
      bmiOptimalMax: _toDouble(json['bmi_optimal_max'] ?? json['bmiOptimalMax']),
      bloodPressureSystolicNormal: _toInt(json['blood_pressure_systolic_normal'] ?? json['bloodPressureSystolicNormal']),
      bloodPressureDiastolicNormal: _toInt(json['blood_pressure_diastolic_normal'] ?? json['bloodPressureDiastolicNormal']),
      doctorNotes: json['doctor_notes'] ?? json['doctorNotes'],
    );
  }

  /// 从后端个性化分析API返回的简化格式解析
  /// 后端返回格式如: { recommendedDailySteps: 10000, recommendedHeartRateRange: "60-100 bpm", ... }
  factory PersonalizedHealthStandards.fromSimplifiedJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? userInfo,
  ) {
    // 解析心率范围 "60-100 bpm"
    int? hrMin, hrMax;
    final hrRange = json['recommendedHeartRateRange'] as String?;
    if (hrRange != null) {
      final match = RegExp(r'(\d+)-(\d+)').firstMatch(hrRange);
      if (match != null) {
        hrMin = int.tryParse(match.group(1) ?? '');
        hrMax = int.tryParse(match.group(2) ?? '');
      }
    }

    // 解析BMI范围 "18.5-24"
    double? bmiMin, bmiMax;
    final bmiRange = json['bmiOptimalRange'] as String?;
    if (bmiRange != null) {
      final match = RegExp(r'([\d.]+)-([\d.]+)').firstMatch(bmiRange);
      if (match != null) {
        bmiMin = double.tryParse(match.group(1) ?? '');
        bmiMax = double.tryParse(match.group(2) ?? '');
      }
    }

    // 解析血压 "120/80 mmHg"
    int? bpSys, bpDia;
    final bpNormal = json['bloodPressureNormal'] as String?;
    if (bpNormal != null) {
      final match = RegExp(r'(\d+)/(\d+)').firstMatch(bpNormal);
      if (match != null) {
        bpSys = int.tryParse(match.group(1) ?? '');
        bpDia = int.tryParse(match.group(2) ?? '');
      }
    }

    return PersonalizedHealthStandards(
      userId: userInfo?['id']?.toString(),
      username: userInfo?['nickname'],
      gender: userInfo?['gender'],
      ageGroup: userInfo?['ageGroup'],
      activityLevel: userInfo?['activityLevel'],
      healthCondition: userInfo?['healthCondition'],
      recommendedDailySteps: _toInt(json['recommendedDailySteps']),
      recommendedHeartRateMin: hrMin,
      recommendedHeartRateMax: hrMax,
      recommendedSleepHours: _toDouble(json['recommendedSleepHours']),
      recommendedWaterMl: _toInt(json['recommendedWaterMl']),
      bmiOptimalMin: bmiMin,
      bmiOptimalMax: bmiMax,
      bloodPressureSystolicNormal: bpSys,
      bloodPressureDiastolicNormal: bpDia,
      bloodPressureNormalString: json['bloodPressureNormal'],
    );
  }
}

/// 个性化健康分析
class PersonalizedHealthAnalysis {
  final PersonalizedHealthStandards? personalizedStandards;
  final Map<String, dynamic>? currentStatus;
  final List<HealthMetricAnalysis> metricsAnalysis;
  final int? overallScore;
  final List<PersonalizedRecommendation> recommendations;
  final DateTime? analyzedAt;
  final Map<String, dynamic>? userInfo;
  final Map<String, dynamic>? assessments;

  PersonalizedHealthAnalysis({
    this.personalizedStandards,
    this.currentStatus,
    this.metricsAnalysis = const [],
    this.overallScore,
    this.recommendations = const [],
    this.analyzedAt,
    this.userInfo,
    this.assessments,
  });

  factory PersonalizedHealthAnalysis.fromJson(Map<String, dynamic> json) {
    // 解析评估数据为metricsAnalysis数组
    List<HealthMetricAnalysis> metrics = [];
    
    // 从 assessments 对象中提取指标分析
    if (json['assessments'] != null) {
      final assessments = json['assessments'] as Map<String, dynamic>;
      
      // BMI 评估
      if (assessments['bmi'] != null && assessments['bmi'] is Map) {
        final bmi = assessments['bmi'];
        metrics.add(HealthMetricAnalysis(
          metric: 'bmi',
          currentValue: bmi['bmi'],
          recommendedMin: bmi['min'],
          recommendedMax: bmi['max'],
          status: _mapStatus(bmi['status']),
          advice: bmi['advice'],
        ));
      }
      
      // 步数评估
      if (assessments['steps'] != null && assessments['steps'] is Map) {
        final steps = assessments['steps'];
        metrics.add(HealthMetricAnalysis(
          metric: 'steps',
          currentValue: steps['current'],
          recommendedMin: steps['min'],
          recommendedMax: steps['optimal'],
          status: _mapStatus(steps['status']),
          advice: steps['advice'],
        ));
      }
      
      // 心率评估
      if (assessments['heartRate'] != null && assessments['heartRate'] is Map) {
        final hr = assessments['heartRate'];
        metrics.add(HealthMetricAnalysis(
          metric: 'heart_rate',
          currentValue: hr['current'],
          recommendedMin: hr['min'],
          recommendedMax: hr['normal'],
          status: _mapStatus(hr['status']),
          advice: hr['advice'],
        ));
      }
      
      // 睡眠评估
      if (assessments['sleep'] != null && assessments['sleep'] is Map) {
        final sleep = assessments['sleep'];
        metrics.add(HealthMetricAnalysis(
          metric: 'sleep',
          currentValue: sleep['current'],
          recommendedMin: sleep['min'],
          recommendedMax: sleep['max'],
          status: _mapStatus(sleep['status']),
          advice: sleep['advice'],
        ));
      }
      
      // 血压评估
      if (assessments['bloodPressure'] != null && assessments['bloodPressure'] is Map) {
        final bp = assessments['bloodPressure'];
        // 血压建议值格式为 "120/80 mmHg"
        String? bpRecommendedDisplay;
        if (bp['normalSys'] != null && bp['normalDia'] != null) {
          bpRecommendedDisplay = '${bp['normalSys']}/${bp['normalDia']} mmHg';
        }
        metrics.add(HealthMetricAnalysis(
          metric: 'blood_pressure',
          currentValue: bp['current'],
          recommendedMin: bp['normalDia'],
          recommendedMax: bp['normalSys'],
          recommendedDisplay: bpRecommendedDisplay,
          status: _mapStatus(bp['status']),
          advice: bp['advice'],
        ));
      }
    }
    
    // 也支持直接的 metricsAnalysis 数组格式
    if (json['metricsAnalysis'] != null) {
      metrics = (json['metricsAnalysis'] as List<dynamic>)
          .map((e) => HealthMetricAnalysis.fromJson(e))
          .toList();
    }

    // 解析 recommendations
    List<PersonalizedRecommendation> recs = [];
    if (json['recommendations'] != null && json['recommendations'] is List) {
      recs = (json['recommendations'] as List<dynamic>)
          .map((e) => PersonalizedRecommendation.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 解析 personalizedStandards - 后端返回的是简化格式
    PersonalizedHealthStandards? standards;
    if (json['personalizedStandards'] != null) {
      standards = PersonalizedHealthStandards.fromSimplifiedJson(
        json['personalizedStandards'],
        json['userInfo'],
      );
    }

    return PersonalizedHealthAnalysis(
      personalizedStandards: standards,
      currentStatus: json['currentStatus'],
      metricsAnalysis: metrics,
      overallScore: json['healthScore'] ?? json['overallScore'],
      recommendations: recs,
      analyzedAt: json['analyzedAt'] != null 
          ? DateTime.parse(json['analyzedAt'])
          : null,
      userInfo: json['userInfo'],
      assessments: json['assessments'],
    );
  }

  /// 将后端状态映射为前端状态
  static String _mapStatus(String? status) {
    if (status == null) return 'unknown';
    switch (status) {
      case 'normal':
      case 'optimal':
        return 'good';
      case 'below_optimal':
      case 'elevated':
      case 'very_low':
      case 'excessive':
      case 'insufficient':
        return 'warning';
      case 'below_minimum':
      case 'high':
      case 'underweight':
      case 'overweight':
      case 'obese':
        return 'alert';
      default:
        return 'unknown';
    }
  }
}

/// 健康指标分析
class HealthMetricAnalysis {
  final String metric;
  final dynamic currentValue;
  final dynamic recommendedMin;
  final dynamic recommendedMax;
  final String? recommendedDisplay; // 用于血压等特殊格式的建议值显示
  final String status;
  final String? advice;

  HealthMetricAnalysis({
    required this.metric,
    this.currentValue,
    this.recommendedMin,
    this.recommendedMax,
    this.recommendedDisplay,
    required this.status,
    this.advice,
  });

  factory HealthMetricAnalysis.fromJson(Map<String, dynamic> json) {
    return HealthMetricAnalysis(
      metric: json['metric'] ?? '',
      currentValue: json['currentValue'],
      recommendedMin: json['recommendedMin'],
      recommendedMax: json['recommendedMax'],
      status: json['status'] ?? 'unknown',
      advice: json['advice'],
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'good':
        return '正常';
      case 'warning':
        return '需关注';
      case 'alert':
        return '需改善';
      default:
        return '未知';
    }
  }
}

/// 个性化建议
class PersonalizedRecommendation {
  final String category;
  final String priority;
  final String advice;
  final String? basedOn;

  PersonalizedRecommendation({
    required this.category,
    required this.priority,
    required this.advice,
    this.basedOn,
  });

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) {
    return PersonalizedRecommendation(
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'low',
      advice: json['advice'] ?? '',
      basedOn: json['basedOn'],
    );
  }
}
