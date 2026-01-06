import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/health_analysis_model.dart';
import '../models/today_summary_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/health_service.dart';
import '../services/public_service.dart';
import '../services/health_profile_service.dart';

/// 认证状态枚举
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// 认证状态管理 Provider
class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  late final AuthService _authService;
  late final HealthService _healthService;
  late final PublicService _publicService;
  late final HealthProfileService _healthProfileService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService() {
    _authService = AuthService(_apiService);
    _healthService = HealthService(_apiService);
    _publicService = PublicService(_apiService);
    _healthProfileService = HealthProfileService(_apiService);
    _tryAutoLogin();
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  AuthService get authService => _authService;
  HealthService get healthService => _healthService;
  PublicService get publicService => _publicService;
  HealthProfileService get healthProfileService => _healthProfileService;

  /// 尝试自动登录
  Future<void> _tryAutoLogin() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final refreshToken = prefs.getString('refreshToken');
      final userData = prefs.getString('userData');

      if (accessToken != null && refreshToken != null && userData != null) {
        _apiService.setTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        _user = User.fromJson(json.decode(userData));
        
        // 尝试获取最新用户信息
        try {
          _user = await _authService.getProfile();
          await _saveUserData();
        } catch (e) {
          // Token 可能过期，尝试刷新
          try {
            await _authService.refreshToken();
            _user = await _authService.getProfile();
            await _saveUserData();
          } catch (e) {
            await _clearUserData();
            _status = AuthStatus.unauthenticated;
            notifyListeners();
            return;
          }
        }

        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// 注册
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? nickname,
    double? height,
    String? gender,
    String? birthday,
    bool generateMockData = false,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
        nickname: nickname,
        height: height,
        gender: gender,
        birthday: birthday,
        generateMockData: generateMockData,
      );

      _user = response.user;
      await _saveTokens(response.accessToken, response.refreshToken);
      await _saveUserData();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '注册失败: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// 登录
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      debugPrint('开始登录: $identifier');
      final response = await _authService.login(
        identifier: identifier,
        password: password,
      );
      debugPrint('登录成功，用户: ${response.user.username}');

      _user = response.user;
      await _saveTokens(response.accessToken, response.refreshToken);
      await _saveUserData();
      debugPrint('Token和用户数据已保存');
      
      _status = AuthStatus.authenticated;
      debugPrint('状态已更新为: $_status');
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      debugPrint('登录失败(ApiException): ${e.message}');
      _error = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('登录失败(未知错误): $e');
      _error = '登录失败: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    _authService.logout();
    await _clearUserData();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// 更新个人信息
  Future<bool> updateProfile({
    String? nickname,
    double? height,
    String? gender,
    String? birthday,
  }) async {
    try {
      _user = await _authService.updateProfile(
        nickname: nickname,
        height: height,
        gender: gender,
        birthday: birthday,
      );
      await _saveUserData();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '更新失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 修改密码
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '修改密码失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    try {
      _user = await _authService.getProfile();
      await _saveUserData();
      notifyListeners();
    } catch (e) {
      // 忽略错误
    }
  }

  // 私有方法
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<void> _saveUserData() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(_user!.toJson()));
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userData');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 健康数据 Provider
class HealthDataProvider with ChangeNotifier {
  final HealthService _healthService;

  HealthAnalysis? _analysis;
  TodaySummary? _todaySummary;
  HealthGoals? _goals;
  bool _isLoading = false;
  String? _error;

  HealthDataProvider(this._healthService);

  // Getters
  HealthAnalysis? get analysis => _analysis;
  TodaySummary? get todaySummary => _todaySummary;
  HealthGoals? get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载所有健康数据
  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadAnalysis(),
        _loadTodaySummary(),
        _loadGoals(),
      ]);
    } catch (e) {
      _error = '加载数据失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAnalysis() async {
    try {
      _analysis = await _healthService.getAnalysis();
    } catch (e) {
      // 忽略单项错误
    }
  }

  Future<void> _loadTodaySummary() async {
    try {
      _todaySummary = await _healthService.getTodaySummary();
    } catch (e) {
      // 忽略单项错误
    }
  }

  Future<void> _loadGoals() async {
    try {
      _goals = await _healthService.getGoals();
    } catch (e) {
      // 忽略单项错误
    }
  }

  /// 刷新分析数据
  Future<void> refreshAnalysis() async {
    try {
      _analysis = await _healthService.getAnalysis();
      notifyListeners();
    } catch (e) {
      _error = '刷新失败: $e';
      notifyListeners();
    }
  }

  /// 刷新今日概览
  Future<void> refreshTodaySummary() async {
    try {
      _todaySummary = await _healthService.getTodaySummary();
      notifyListeners();
    } catch (e) {
      _error = '刷新失败: $e';
      notifyListeners();
    }
  }

  /// 更新目标
  Future<bool> updateGoals(HealthGoals goals) async {
    try {
      _goals = await _healthService.updateGoals(goals);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '更新目标失败: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
