import '../core/constants/api_constants.dart';
import '../models/health_profile_model.dart';
import 'api_service.dart';

/// 个性化健康档案服务
class HealthProfileService {
  final ApiService _api;

  HealthProfileService(this._api);

  /// 获取用户健康档案
  Future<UserHealthProfile?> getProfile() async {
    try {
      final response = await _api.get(
        ApiConstants.healthProfile,
        requireAuth: true,
      );
      
      final data = response['data'];
      // 如果返回的是提示消息而非档案数据
      if (data is Map && data.containsKey('message') && !data.containsKey('id')) {
        return null;
      }
      return UserHealthProfile.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 创建或更新健康档案
  Future<UserHealthProfile> saveProfile(UserHealthProfile profile) async {
    final response = await _api.post(
      ApiConstants.healthProfile,
      body: profile.toJson(),
      requireAuth: true,
    );
    return UserHealthProfile.fromJson(response['data']);
  }

  /// 删除健康档案
  Future<void> deleteProfile() async {
    await _api.delete(
      ApiConstants.healthProfile,
      requireAuth: true,
    );
  }

  /// 获取个性化健康标准
  Future<PersonalizedHealthStandards?> getPersonalizedStandards() async {
    try {
      final response = await _api.get(
        ApiConstants.healthProfileStandards,
        requireAuth: true,
      );
      
      final data = response['data'];
      // 如果返回的是提示消息而非标准数据
      if (data is Map && data.containsKey('message') && !data.containsKey('recommended_daily_steps')) {
        return null;
      }
      return PersonalizedHealthStandards.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取个性化健康分析
  Future<PersonalizedHealthAnalysis> getPersonalizedAnalysis() async {
    final response = await _api.get(
      ApiConstants.healthProfileAnalysis,
      requireAuth: true,
    );
    return PersonalizedHealthAnalysis.fromJson(response['data']);
  }

  /// 更新医生建议
  Future<UserHealthProfile> updateDoctorNotes(String notes) async {
    final response = await _api.put(
      ApiConstants.healthProfileDoctorNotes,
      body: {'doctorNotes': notes},
      requireAuth: true,
    );
    return UserHealthProfile.fromJson(response['data']);
  }
}
