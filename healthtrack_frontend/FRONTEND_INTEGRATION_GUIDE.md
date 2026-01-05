# 前端集成指南 - 个性化健康评估系统

## 📱 概述

本指南帮助前端开发者快速集成个性化健康评估功能到 Flutter/Web 应用中。

---

## 🎯 核心流程

```
1. 用户登录
   ↓
2. 检查是否有个性化档案
   ↓
3. 如果没有 → 显示档案完善引导
   ↓
4. 上传健康数据 (步数、心率、睡眠等)
   ↓
5. 获取个性化分析报告
   ↓
6. 展示个性化建议
```

---

## 🔑 API 快速参考

### 基础信息
- **基础URL**: `http://localhost:3000/api/health-profile`
- **认证方式**: Bearer Token (在请求头中)

### 关键端点

| 功能 | 方法 | 端点 | 说明 |
|------|------|------|------|
| 获取档案 | GET | `/` | 获取用户的健康档案 |
| 创建档案 | POST | `/` | 创建或更新档案 |
| 获取标准 | GET | `/standards` | 获取个性化标准 |
| 分析报告 | GET | `/analysis/personalized` | 获取个性化分析 |

---

## 💻 前端代码示例

### 1️⃣ Dart/Flutter 实现

```dart
// lib/services/personalizedHealthService.dart

import 'package:dio/dio.dart';

class PersonalizedHealthService {
  final Dio _dio;
  
  PersonalizedHealthService(this._dio);
  
  // 获取用户个性化档案
  Future<Map<String, dynamic>> getHealthProfile(String token) async {
    try {
      final response = await _dio.get(
        '/api/health-profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } catch (e) {
      print('获取档案失败: $e');
      rethrow;
    }
  }
  
  // 创建或更新个性化档案
  Future<Map<String, dynamic>> updateHealthProfile({
    required String token,
    required String ageGroup,
    String activityLevel = 'moderately_active',
    String healthCondition = 'good',
    bool hasCardiovascularIssues = false,
    bool hasDiabetes = false,
    bool hasJointIssues = false,
    bool isPregnant = false,
    bool isRecovering = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/health-profile',
        data: {
          'ageGroup': ageGroup,
          'activityLevel': activityLevel,
          'healthCondition': healthCondition,
          'hasCardiovascularIssues': hasCardiovascularIssues,
          'hasDiabetes': hasDiabetes,
          'hasJointIssues': hasJointIssues,
          'isPregnant': isPregnant,
          'isRecovering': isRecovering,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } catch (e) {
      print('更新档案失败: $e');
      rethrow;
    }
  }
  
  // 获取个性化健康标准
  Future<Map<String, dynamic>> getPersonalizedStandards(String token) async {
    try {
      final response = await _dio.get(
        '/api/health-profile/standards',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } catch (e) {
      print('获取标准失败: $e');
      rethrow;
    }
  }
  
  // 获取个性化健康分析报告
  Future<Map<String, dynamic>> getPersonalizedAnalysis(String token) async {
    try {
      final response = await _dio.get(
        '/api/health-profile/analysis/personalized',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } catch (e) {
      print('获取分析报告失败: $e');
      rethrow;
    }
  }
}
```

### 2️⃣ 数据模型

```dart
// lib/models/personalized_health_model.dart

class HealthProfile {
  final String id;
  final String userId;
  final String ageGroup;
  final String activityLevel;
  final String healthCondition;
  final bool hasCardiovascularIssues;
  final bool hasDiabetes;
  final bool hasJointIssues;
  final bool isPregnant;
  final bool isRecovering;
  final int? personalizedStepsGoal;
  final String? doctorNotes;
  
  HealthProfile({
    required this.id,
    required this.userId,
    required this.ageGroup,
    required this.activityLevel,
    required this.healthCondition,
    required this.hasCardiovascularIssues,
    required this.hasDiabetes,
    required this.hasJointIssues,
    required this.isPregnant,
    required this.isRecovering,
    this.personalizedStepsGoal,
    this.doctorNotes,
  });
  
  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      ageGroup: json['age_group'] ?? 'adult',
      activityLevel: json['activity_level'] ?? 'moderately_active',
      healthCondition: json['health_condition'] ?? 'good',
      hasCardiovascularIssues: json['has_cardiovascular_issues'] == 1,
      hasDiabetes: json['has_diabetes'] == 1,
      hasJointIssues: json['has_joint_issues'] == 1,
      isPregnant: json['is_pregnant'] == 1,
      isRecovering: json['is_recovering'] == 1,
      personalizedStepsGoal: json['personalized_steps_goal'],
      doctorNotes: json['doctor_notes'],
    );
  }
}

class PersonalizedAnalysis {
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> currentStatus;
  final Map<String, dynamic> assessments;
  final int healthScore;
  final List<Recommendation> recommendations;
  final Map<String, dynamic> personalizedStandards;
  
  PersonalizedAnalysis({
    required this.userInfo,
    required this.currentStatus,
    required this.assessments,
    required this.healthScore,
    required this.recommendations,
    required this.personalizedStandards,
  });
  
  factory PersonalizedAnalysis.fromJson(Map<String, dynamic> json) {
    final List<Recommendation> recs = (json['recommendations'] as List)
        .map((r) => Recommendation.fromJson(r))
        .toList();
    
    return PersonalizedAnalysis(
      userInfo: json['userInfo'] ?? {},
      currentStatus: json['currentStatus'] ?? {},
      assessments: json['assessments'] ?? {},
      healthScore: json['healthScore'] ?? 0,
      recommendations: recs,
      personalizedStandards: json['personalizedStandards'] ?? {},
    );
  }
}

class Recommendation {
  final String category;
  final String priority; // 'high', 'medium', 'low'
  final String advice;
  
  Recommendation({
    required this.category,
    required this.priority,
    required this.advice,
  });
  
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'low',
      advice: json['advice'] ?? '',
    );
  }
}
```

### 3️⃣ Provider 状态管理

```dart
// lib/providers/personalized_health_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/personalizedHealthService.dart';
import '../models/personalized_health_model.dart';

class PersonalizedHealthProvider extends ChangeNotifier {
  final PersonalizedHealthService _service;
  
  HealthProfile? _profile;
  PersonalizedAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;
  
  PersonalizedHealthProvider(this._service);
  
  // Getters
  HealthProfile? get profile => _profile;
  PersonalizedAnalysis? get analysis => _analysis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;
  int get healthScore => _analysis?.healthScore ?? 0;
  List<Recommendation> get recommendations => _analysis?.recommendations ?? [];
  
  // 加载个性化档案
  Future<void> loadHealthProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _service.getHealthProfile(token);
      if (response['success']) {
        _profile = HealthProfile.fromJson(response['data']);
      } else {
        _error = response['message'] ?? '加载失败';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 保存/更新档案
  Future<void> saveHealthProfile({
    required String token,
    required String ageGroup,
    String activityLevel = 'moderately_active',
    String healthCondition = 'good',
    bool hasCardiovascularIssues = false,
    bool hasDiabetes = false,
    bool hasJointIssues = false,
    bool isPregnant = false,
    bool isRecovering = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _service.updateHealthProfile(
        token: token,
        ageGroup: ageGroup,
        activityLevel: activityLevel,
        healthCondition: healthCondition,
        hasCardiovascularIssues: hasCardiovascularIssues,
        hasDiabetes: hasDiabetes,
        hasJointIssues: hasJointIssues,
        isPregnant: isPregnant,
        isRecovering: isRecovering,
      );
      
      if (response['success']) {
        _profile = HealthProfile.fromJson(response['data']);
      } else {
        _error = response['message'] ?? '保存失败';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 加载个性化分析
  Future<void> loadPersonalizedAnalysis(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _service.getPersonalizedAnalysis(token);
      if (response['success']) {
        _analysis = PersonalizedAnalysis.fromJson(response['data']);
      } else {
        _error = response['message'] ?? '加载分析失败';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 4️⃣ UI 集成示例

```dart
// lib/screens/personalized_health_screen.dart

class PersonalizedHealthScreen extends StatefulWidget {
  @override
  _PersonalizedHealthScreenState createState() =>
      _PersonalizedHealthScreenState();
}

class _PersonalizedHealthScreenState extends State<PersonalizedHealthScreen> {
  late String _token;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    final provider = context.read<PersonalizedHealthProvider>();
    // 获取 token（从 AuthProvider 或本地存储）
    provider.loadHealthProfile(_token);
    provider.loadPersonalizedAnalysis(_token);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个性化健康分析'),
      ),
      body: Consumer<PersonalizedHealthProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!provider.hasProfile) {
            return _buildSetupProfile();
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileInfo(provider),
                _buildHealthScoreCard(provider),
                _buildAssessmentsSection(provider),
                _buildRecommendationsSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSetupProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('完善你的健康档案'),
          SizedBox(height: 8),
          Text('这样我们就能给你个性化的健康建议'),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // 导航到档案编辑页面
            },
            child: Text('立即设置'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileInfo(PersonalizedHealthProvider provider) {
    final profile = provider.profile;
    if (profile == null) return SizedBox.shrink();
    
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('你的健康档案', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildInfoRow('年龄段', _ageGroupLabel(profile.ageGroup)),
            _buildInfoRow('运动水平', _activityLevelLabel(profile.activityLevel)),
            _buildInfoRow('健康状况', _healthConditionLabel(profile.healthCondition)),
            if (profile.isPregnant)
              _buildInfoRow('特殊情况', '孕期 🤰', color: Colors.orange),
            if (profile.hasCardiovascularIssues)
              _buildInfoRow('特殊情况', '心血管问题 ❤️', color: Colors.red),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHealthScoreCard(PersonalizedHealthProvider provider) {
    final score = provider.healthScore;
    final color = score >= 80 ? Colors.green :
                  score >= 60 ? Colors.orange :
                  Colors.red;
    
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('个性化健康评分', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              _getHealthStatus(score),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssessmentsSection(PersonalizedHealthProvider provider) {
    final analysis = provider.analysis;
    if (analysis == null) return SizedBox.shrink();
    
    final assessments = analysis.assessments;
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('详细评估', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          if (assessments['steps'] != null)
            _buildAssessmentCard(
              title: '步数',
              assessment: assessments['steps'],
              icon: Icons.directions_walk,
            ),
          if (assessments['sleep'] != null)
            _buildAssessmentCard(
              title: '睡眠',
              assessment: assessments['sleep'],
              icon: Icons.hotel,
            ),
          if (assessments['heartRate'] != null)
            _buildAssessmentCard(
              title: '心率',
              assessment: assessments['heartRate'],
              icon: Icons.favorite,
            ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationsSection(PersonalizedHealthProvider provider) {
    final recs = provider.recommendations;
    
    if (recs.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('个性化建议', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ...recs.map((rec) => _buildRecommendationItem(rec)).toList(),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationItem(Recommendation rec) {
    final color = rec.priority == 'high' ? Colors.red :
                  rec.priority == 'medium' ? Colors.orange :
                  Colors.green;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: color,
                ),
                SizedBox(width: 8),
                Text(
                  rec.category,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Chip(
                  label: Text(rec.priority.toUpperCase()),
                  backgroundColor: color.withOpacity(0.2),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(rec.advice),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssessmentCard({
    required String title,
    required Map<String, dynamic> assessment,
    required IconData icon,
  }) {
    final status = assessment['status'] ?? '';
    final advice = assessment['advice'] ?? '';
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(advice, style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
  
  String _ageGroupLabel(String ageGroup) {
    final labels = {
      'child': '儿童 (0-12岁)',
      'teen': '青少年 (13-18岁)',
      'adult': '成人 (19-40岁)',
      'middle_age': '中年 (41-65岁)',
      'senior': '老年 (65岁+)',
    };
    return labels[ageGroup] ?? ageGroup;
  }
  
  String _activityLevelLabel(String level) {
    final labels = {
      'sedentary': '久坐',
      'lightly_active': '轻度活动',
      'moderately_active': '中等活动',
      'very_active': '经常运动',
      'extremely_active': '高强度运动',
    };
    return labels[level] ?? level;
  }
  
  String _healthConditionLabel(String condition) {
    final labels = {
      'excellent': '非常好',
      'good': '良好',
      'fair': '一般',
      'poor': '需要改善',
    };
    return labels[condition] ?? condition;
  }
  
  String _getHealthStatus(int score) {
    if (score >= 80) return '很好！继续保持 🎉';
    if (score >= 60) return '还不错，还有改进空间 💪';
    return '需要关注，建议加强锻炼 ⚠️';
  }
}
```

---

## 🔌 Web 版本 (React/Vue)

### React 示例

```javascript
// src/services/personalizedHealthService.js

export const personalizedHealthService = {
  getProfile: async (token) => {
    const response = await fetch('/api/health-profile', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return response.json();
  },
  
  updateProfile: async (token, data) => {
    const response = await fetch('/api/health-profile', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(data)
    });
    return response.json();
  },
  
  getAnalysis: async (token) => {
    const response = await fetch('/api/health-profile/analysis/personalized', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return response.json();
  }
};

// src/components/PersonalizedHealthAnalysis.jsx

import React, { useState, useEffect } from 'react';
import { personalizedHealthService } from '../services/personalizedHealthService';

export function PersonalizedHealthAnalysis({ token }) {
  const [analysis, setAnalysis] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const loadAnalysis = async () => {
      try {
        const data = await personalizedHealthService.getAnalysis(token);
        if (data.success) {
          setAnalysis(data.data);
        }
      } catch (error) {
        console.error('加载分析失败:', error);
      } finally {
        setLoading(false);
      }
    };
    
    loadAnalysis();
  }, [token]);
  
  if (loading) return <div>加载中...</div>;
  if (!analysis) return <div>暂无数据</div>;
  
  const { healthScore, recommendations, assessments } = analysis;
  
  return (
    <div className="personalized-health">
      <h2>个性化健康分析</h2>
      
      <div className="health-score">
        <div className="score-circle" style={{ width: 150, height: 150 }}>
          <span className="score">{healthScore}</span>
        </div>
        <p>{getHealthStatus(healthScore)}</p>
      </div>
      
      <div className="recommendations">
        <h3>个性化建议</h3>
        {recommendations.map((rec, idx) => (
          <div key={idx} className={`recommendation ${rec.priority}`}>
            <strong>{rec.category}</strong>
            <p>{rec.advice}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

function getHealthStatus(score) {
  if (score >= 80) return '很好！继续保持 🎉';
  if (score >= 60) return '还不错，还有改进空间 💪';
  return '需要关注，建议加强锻炼 ⚠️';
}
```

---

## 🎨 前端页面建议

### 1. 档案设置页面
- [ ] 年龄段选择
- [ ] 运动水平选择
- [ ] 健康状况评估
- [ ] 特殊条件复选框
- [ ] 保存/更新按钮

### 2. 分析展示页面
- [ ] 健康评分圆形图
- [ ] 各项评估卡片
- [ ] 优先级排序的建议列表
- [ ] 分享功能

### 3. 详细数据页面
- [ ] 当前状态（步数、心率、睡眠等）
- [ ] 个性化标准对比
- [ ] 达成度进度条
- [ ] 历史趋势图表

---

## 📲 通知提醒建议

```
高优先级建议（High）→ 红色，推送通知
中优先级建议（Medium）→ 橙色，应用内提示
低优先级建议（Low）→ 绿色，可选查看
```

---

## 🚀 发布检查清单

- [ ] 后端 API 已部署并测试
- [ ] 前端能正确调用所有接口
- [ ] 错误处理完善
- [ ] 加载状态正确显示
- [ ] 数据展示清晰准确
- [ ] 响应式设计适配各种屏幕
- [ ] 性能优化（减少不必要的重新渲染）
- [ ] 文案本地化

---

## 📞 常见问题

**Q: 如何获取用户的年龄组？**
```dart
// 系统会根据 birthday 字段自动计算
// 或在前端计算：
int calculateAge(DateTime birthday) {
  final now = DateTime.now();
  int age = now.year - birthday.year;
  if (now.month < birthday.month || 
      (now.month == birthday.month && now.day < birthday.day)) {
    age--;
  }
  return age;
}
```

**Q: 如何缓存分析数据？**
```dart
// 使用 shared_preferences 缓存
Future<void> _cacheAnalysis(PersonalizedAnalysis analysis) async {
  final prefs = await SharedPreferences.getInstance();
  final json = jsonEncode(analysis.toJson());
  await prefs.setString('cached_analysis', json);
}
```

**Q: 如何实现自动刷新？**
```dart
// 使用 Timer 定期刷新
Timer.periodic(Duration(hours: 1), (_) {
  provider.loadPersonalizedAnalysis(token);
});
```

---

## 📚 完整集成检查清单

- [ ] 后端部署完成
- [ ] 前端添加服务类
- [ ] 前端添加数据模型
- [ ] 前端添加 Provider/状态管理
- [ ] 前端添加 UI 组件
- [ ] 测试各个 API 端点
- [ ] 处理加载和错误状态
- [ ] 添加本地化文本
- [ ] 测试不同场景
- [ ] 性能优化
- [ ] 文档完善
- [ ] 用户教程/引导

---

更多细节请参考 `PERSONALIZED_HEALTH_API.md` 和 `DEPLOYMENT_GUIDE.md`
