import '../core/utils/parse_utils.dart';

/// 健康记录模型
class HealthRecord {
  final String? id;
  final String? userId;
  final String type;
  final double value;
  final String? note;
  final String recordDate;
  final DateTime? createdAt;

  HealthRecord({
    this.id,
    this.userId,
    required this.type,
    required this.value,
    this.note,
    required this.recordDate,
    this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      userId: json['userId'],
      type: json['type'] ?? '',
      value: ParseUtils.toDouble(json['value']),
      note: json['note'],
      recordDate: json['recordDate'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      if (note != null && note!.isNotEmpty) 'note': note,
      'recordDate': recordDate,
    };
  }

  HealthRecord copyWith({
    String? id,
    String? userId,
    String? type,
    double? value,
    String? note,
    String? recordDate,
    DateTime? createdAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      value: value ?? this.value,
      note: note ?? this.note,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 健康记录列表响应
class HealthRecordsResponse {
  final List<HealthRecord> records;
  final Pagination pagination;

  HealthRecordsResponse({
    required this.records,
    required this.pagination,
  });

  factory HealthRecordsResponse.fromJson(Map<String, dynamic> json) {
    return HealthRecordsResponse(
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => HealthRecord.fromJson(e))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

/// 分页信息
class Pagination {
  final int total;
  final int limit;
  final int offset;

  Pagination({
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 100,
      offset: json['offset'] ?? 0,
    );
  }
}

/// 趋势数据点
class TrendDataPoint {
  final String date;
  final double value;
  final int count;

  TrendDataPoint({
    required this.date,
    required this.value,
    required this.count,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: json['date'] ?? '',
      value: ParseUtils.toDouble(json['value']),
      count: ParseUtils.toInt(json['count']),
    );
  }
}

/// 趋势数据响应
class TrendResponse {
  final String type;
  final String period;
  final String startDate;
  final String endDate;
  final List<TrendDataPoint> data;

  TrendResponse({
    required this.type,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.data,
  });

  factory TrendResponse.fromJson(Map<String, dynamic> json) {
    return TrendResponse(
      type: json['type'] ?? '',
      period: json['period'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TrendDataPoint.fromJson(e))
          .toList() ?? [],
    );
  }
}
