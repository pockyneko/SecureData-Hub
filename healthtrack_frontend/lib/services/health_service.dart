import '../core/constants/api_constants.dart';
import '../models/health_record_model.dart';
import '../models/health_analysis_model.dart';
import '../models/today_summary_model.dart';
import 'api_service.dart';

/// 健康数据服务
class HealthService {
  final ApiService _api;

  HealthService(this._api);

  /// 获取健康记录列表
  Future<HealthRecordsResponse> getRecords({
    String? type,
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _api.get(
      ApiConstants.healthRecords,
      queryParams: queryParams,
      requireAuth: true,
    );
    return HealthRecordsResponse.fromJson(response['data']);
  }

  /// 创建健康记录
  Future<HealthRecord> createRecord({
    required String type,
    required double value,
    String? note,
    String? recordDate,
  }) async {
    final body = {
      'type': type,
      'value': value,
      if (note != null) 'note': note,
      if (recordDate != null) 'recordDate': recordDate,
    };

    final response = await _api.post(
      ApiConstants.healthRecords,
      body: body,
      requireAuth: true,
    );
    return HealthRecord.fromJson(response['data']);
  }

  /// 批量创建健康记录
  Future<List<HealthRecord>> createRecordsBatch(List<HealthRecord> records) async {
    final response = await _api.post(
      ApiConstants.healthRecordsBatch,
      body: {
        'records': records.map((r) => r.toJson()).toList(),
      },
      requireAuth: true,
    );
    
    final data = response['data'];
    if (data['records'] != null) {
      return (data['records'] as List)
          .map((e) => HealthRecord.fromJson(e))
          .toList();
    }
    return [];
  }

  /// 更新健康记录
  Future<HealthRecord> updateRecord(
    String id, {
    double? value,
    String? note,
  }) async {
    final body = {
      if (value != null) 'value': value,
      if (note != null) 'note': note,
    };

    final response = await _api.put(
      '${ApiConstants.healthRecords}/$id',
      body: body,
      requireAuth: true,
    );
    return HealthRecord.fromJson(response['data']);
  }

  /// 删除健康记录
  Future<void> deleteRecord(String id) async {
    await _api.delete(
      '${ApiConstants.healthRecords}/$id',
      requireAuth: true,
    );
  }

  /// 获取健康分析报告
  Future<HealthAnalysis> getAnalysis() async {
    final response = await _api.get(
      ApiConstants.healthAnalysis,
      requireAuth: true,
    );
    return HealthAnalysis.fromJson(response['data']);
  }

  /// 获取趋势数据
  Future<TrendResponse> getTrends(
    String type, {
    String period = 'week',
  }) async {
    final response = await _api.get(
      '${ApiConstants.healthTrends}/$type',
      queryParams: {'period': period},
      requireAuth: true,
    );
    return TrendResponse.fromJson(response['data']);
  }

  /// 获取今日概览
  Future<TodaySummary> getTodaySummary() async {
    final response = await _api.get(
      ApiConstants.healthToday,
      requireAuth: true,
    );
    return TodaySummary.fromJson(response['data']);
  }

  /// 获取用户目标
  Future<HealthGoals> getGoals() async {
    final response = await _api.get(
      ApiConstants.healthGoals,
      requireAuth: true,
    );
    return HealthGoals.fromJson(response['data']);
  }

  /// 更新用户目标
  Future<HealthGoals> updateGoals(HealthGoals goals) async {
    final response = await _api.put(
      ApiConstants.healthGoals,
      body: goals.toJson(),
      requireAuth: true,
    );
    return HealthGoals.fromJson(response['data']);
  }

  /// 生成模拟数据
  Future<MockDataResult> generateMockData({
    int days = 30,
    bool demoMode = false,
  }) async {
    final response = await _api.post(
      ApiConstants.healthMockData,
      body: {
        'days': days,
        'demoMode': demoMode,
      },
      requireAuth: true,
    );
    return MockDataResult(
      success: response['success'] ?? false,
      insertedCount: response['data']['insertedCount'] ?? 0,
      message: response['data']['message'],
    );
  }
}

/// 模拟数据结果
class MockDataResult {
  final bool success;
  final int insertedCount;
  final String? message;

  MockDataResult({
    required this.success,
    required this.insertedCount,
    this.message,
  });
}
