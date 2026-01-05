import '../core/utils/parse_utils.dart';

/// 今日概览模型
class TodaySummary {
  final String date;
  final Map<String, SummaryItem> summary;
  final GoalProgress goalProgress;

  TodaySummary({
    required this.date,
    required this.summary,
    required this.goalProgress,
  });

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    Map<String, SummaryItem> summaryMap = {};
    if (json['summary'] != null) {
      (json['summary'] as Map<String, dynamic>).forEach((key, value) {
        summaryMap[key] = SummaryItem.fromJson(value);
      });
    }

    return TodaySummary(
      date: json['date'] ?? '',
      summary: summaryMap,
      goalProgress: GoalProgress.fromJson(json['goalProgress'] ?? {}),
    );
  }

  SummaryItem? getItem(String type) => summary[type];
}

/// 概览项
class SummaryItem {
  final String type;
  final double value;
  final int count;
  final double latest;

  SummaryItem({
    required this.type,
    required this.value,
    required this.count,
    required this.latest,
  });

  factory SummaryItem.fromJson(Map<String, dynamic> json) {
    return SummaryItem(
      type: json['type'] ?? '',
      value: ParseUtils.toDouble(json['value']),
      count: ParseUtils.toInt(json['count']),
      latest: ParseUtils.toDouble(json['latest']),
    );
  }
}

/// 目标进度
class GoalProgress {
  final ProgressItem? steps;
  final ProgressItem? water;
  final ProgressItem? sleep;
  final ProgressItem? calories;

  GoalProgress({
    this.steps,
    this.water,
    this.sleep,
    this.calories,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      steps: json['steps'] != null ? ProgressItem.fromJson(json['steps']) : null,
      water: json['water'] != null ? ProgressItem.fromJson(json['water']) : null,
      sleep: json['sleep'] != null ? ProgressItem.fromJson(json['sleep']) : null,
      calories: json['calories'] != null ? ProgressItem.fromJson(json['calories']) : null,
    );
  }
}

/// 进度项
class ProgressItem {
  final double current;
  final double goal;
  final double percentage;

  ProgressItem({
    required this.current,
    required this.goal,
    required this.percentage,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      current: ParseUtils.toDouble(json['current']),
      goal: ParseUtils.toDouble(json['goal']),
      percentage: ParseUtils.toDouble(json['percentage']),
    );
  }
}
