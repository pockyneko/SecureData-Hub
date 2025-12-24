import '../core/utils/parse_utils.dart';

/// 用户模型
class User {
  final String id;
  final String username;
  final String email;
  final String? nickname;
  final String? avatar;
  final double? height;
  final String? gender;
  final String? birthday;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.nickname,
    this.avatar,
    this.height,
    this.gender,
    this.birthday,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'],
      avatar: json['avatar'],
      height: json['height'] != null ? ParseUtils.toDouble(json['height']) : null,
      gender: json['gender'],
      birthday: json['birthday'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'height': height,
      'gender': gender,
      'birthday': birthday,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? nickname,
    String? avatar,
    double? height,
    String? gender,
    String? birthday,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayName => nickname ?? username;

  String get genderDisplay {
    switch (gender) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      case 'other':
        return '其他';
      default:
        return '未设置';
    }
  }
}

/// 认证响应模型
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final MockDataResult? mockData;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.mockData,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      mockData: json['mockData'] != null 
          ? MockDataResult.fromJson(json['mockData'])
          : null,
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

  factory MockDataResult.fromJson(Map<String, dynamic> json) {
    return MockDataResult(
      success: json['success'] ?? false,
      insertedCount: json['insertedCount'] ?? 0,
      message: json['message'],
    );
  }
}
