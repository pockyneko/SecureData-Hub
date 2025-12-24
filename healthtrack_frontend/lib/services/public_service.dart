import '../core/constants/api_constants.dart';
import '../models/public_models.dart';
import 'api_service.dart';

/// 公开服务（无需认证）
class PublicService {
  final ApiService _api;

  PublicService(this._api);

  /// 获取健康百科列表
  Future<List<HealthTip>> getTips({
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (category != null) queryParams['category'] = category;

    final response = await _api.get(
      ApiConstants.publicTips,
      queryParams: queryParams,
    );
    
    final tips = response['data']['tips'] as List<dynamic>?;
    return tips?.map((e) => HealthTip.fromJson(e)).toList() ?? [];
  }

  /// 获取健康百科分类
  Future<List<String>> getTipCategories() async {
    final response = await _api.get(ApiConstants.publicTipsCategories);
    return (response['data'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
  }

  /// 获取运动推荐
  Future<ExerciseRecommendationsResponse> getExerciseRecommendations({
    String? weather,
    String? timeSlot,
    int limit = 5,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (weather != null) queryParams['weather'] = weather;
    if (timeSlot != null) queryParams['timeSlot'] = timeSlot;

    final response = await _api.get(
      ApiConstants.publicExercises,
      queryParams: queryParams,
    );
    return ExerciseRecommendationsResponse.fromJson(response['data']);
  }

  /// 获取每日健康贴士
  Future<HealthTip> getDailyTip() async {
    final response = await _api.get(ApiConstants.publicDailyTip);
    return HealthTip.fromJson(response['data']);
  }
}
