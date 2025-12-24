/// 健康百科模型
class HealthTip {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final DateTime? createdAt;

  HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.createdAt,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }
}

/// 运动推荐模型
class ExerciseRecommendation {
  final String id;
  final String name;
  final String description;
  final String intensity;
  final int duration;
  final int caloriesBurned;
  final String? imageUrl;

  ExerciseRecommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.intensity,
    required this.duration,
    required this.caloriesBurned,
    this.imageUrl,
  });

  factory ExerciseRecommendation.fromJson(Map<String, dynamic> json) {
    return ExerciseRecommendation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      intensity: json['intensity'] ?? '',
      duration: json['duration'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  String get intensityDisplay {
    switch (intensity) {
      case 'low':
        return '低强度';
      case 'medium':
        return '中等强度';
      case 'high':
        return '高强度';
      default:
        return intensity;
    }
  }
}

/// 运动推荐响应
class ExerciseRecommendationsResponse {
  final ExerciseConditions conditions;
  final String message;
  final List<ExerciseRecommendation> recommendations;

  ExerciseRecommendationsResponse({
    required this.conditions,
    required this.message,
    required this.recommendations,
  });

  factory ExerciseRecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseRecommendationsResponse(
      conditions: ExerciseConditions.fromJson(json['conditions'] ?? {}),
      message: json['message'] ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => ExerciseRecommendation.fromJson(e))
          .toList() ?? [],
    );
  }
}

/// 推荐条件
class ExerciseConditions {
  final String weather;
  final String timeSlot;

  ExerciseConditions({
    required this.weather,
    required this.timeSlot,
  });

  factory ExerciseConditions.fromJson(Map<String, dynamic> json) {
    return ExerciseConditions(
      weather: json['weather'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
    );
  }
}
