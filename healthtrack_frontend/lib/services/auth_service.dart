import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// 认证服务
class AuthService {
  final ApiService _api;

  AuthService(this._api);

  /// 用户注册
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? nickname,
    double? height,
    String? gender,
    String? birthday,
    bool generateMockData = false,
  }) async {
    final body = {
      'username': username,
      'email': email,
      'password': password,
      if (nickname != null) 'nickname': nickname,
      if (height != null) 'height': height,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': birthday,
      'generateMockData': generateMockData,
    };

    final response = await _api.post(ApiConstants.authRegister, body: body);
    final authResponse = AuthResponse.fromJson(response['data']);
    _api.setTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    return authResponse;
  }

  /// 用户登录
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _api.post(
      ApiConstants.authLogin,
      body: {
        'identifier': identifier,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response['data']);
    _api.setTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    return authResponse;
  }

  /// 刷新 Token
  Future<void> refreshToken() async {
    if (_api.refreshToken == null) {
      throw ApiException(message: '无刷新令牌');
    }

    final response = await _api.post(
      ApiConstants.authRefresh,
      body: {'refreshToken': _api.refreshToken},
    );

    _api.setTokens(
      accessToken: response['data']['accessToken'],
      refreshToken: response['data']['refreshToken'],
    );
  }

  /// 获取个人信息
  Future<User> getProfile() async {
    final response = await _api.get(
      ApiConstants.authProfile,
      requireAuth: true,
    );
    return User.fromJson(response['data']);
  }

  /// 更新个人信息
  Future<User> updateProfile({
    String? nickname,
    double? height,
    String? gender,
    String? birthday,
  }) async {
    final body = {
      if (nickname != null) 'nickname': nickname,
      if (height != null) 'height': height,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': birthday,
    };

    final response = await _api.put(
      ApiConstants.authProfile,
      body: body,
      requireAuth: true,
    );
    return User.fromJson(response['data']);
  }

  /// 修改密码
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.put(
      ApiConstants.authPassword,
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      requireAuth: true,
    );
  }

  /// 登出
  void logout() {
    _api.clearTokens();
  }
}
