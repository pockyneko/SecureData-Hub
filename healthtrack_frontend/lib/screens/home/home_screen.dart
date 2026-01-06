import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/today_summary_model.dart';
import '../../models/public_models.dart';
import '../../models/health_analysis_model.dart';
import '../../models/health_profile_model.dart';
import '../records/add_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TodaySummary? _todaySummary;
  HealthTip? _dailyTip;
  HealthAnalysis? _healthAnalysis;
  UserHealthProfile? _healthProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      // 并行加载数据
      await Future.wait([
        _loadTodaySummary(authProvider),
        _loadDailyTip(authProvider),
        _loadHealthAnalysis(authProvider),
        _loadHealthProfile(authProvider),
      ]);
    } catch (e) {
      debugPrint('加载数据异常: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodaySummary(AuthProvider authProvider) async {
    try {
      _todaySummary = await authProvider.healthService.getTodaySummary();
    } catch (e) {
      debugPrint('获取今日概览失败: $e');
    }
  }

  Future<void> _loadDailyTip(AuthProvider authProvider) async {
    try {
      _dailyTip = await authProvider.publicService.getDailyTip();
    } catch (e) {
      debugPrint('获取每日贴士失败: $e');
    }
  }

  Future<void> _loadHealthAnalysis(AuthProvider authProvider) async {
    try {
      _healthAnalysis = await authProvider.healthService.getAnalysis();
    } catch (e) {
      debugPrint('获取健康分析失败: $e');
    }
  }

  Future<void> _loadHealthProfile(AuthProvider authProvider) async {
    try {
      _healthProfile = await authProvider.healthProfileService.getProfile();
    } catch (e) {
      debugPrint('获取健康档案失败: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，注意休息 🌙';
    if (hour < 9) return '早安，美好的一天开始了 ☀️';
    if (hour < 12) return '上午好，保持活力 💪';
    if (hour < 14) return '中午好，记得午休 😊';
    if (hour < 18) return '下午好，继续加油 🎯';
    if (hour < 22) return '晚上好，放松一下 🌆';
    return '夜深了，早点休息 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '你好，${user?.displayName ?? '用户'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _getGreeting(),
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
        toolbarHeight: 65,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知功能即将上线')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 健康状态总览卡片
                    _buildHealthOverviewCard(),
                    const SizedBox(height: 14),

                    // 今日目标进度
                    _buildGoalProgressSection(),
                    const SizedBox(height: 14),

                    // 快速记录水平滚动
                    _buildQuickRecordSection(),
                    const SizedBox(height: 14),

                    // 今日健康数据
                    _buildTodayDataCard(),
                    const SizedBox(height: 14),

                    // 每日贴士
                    if (_dailyTip != null) _buildDailyTipCard(),
                    
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecordScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('记录', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // 健康状态总览卡片
  Widget _buildHealthOverviewCard() {
    final score = _healthAnalysis?.healthScore ?? 0;
    Color scoreColor;
    String scoreLabel;

    if (score >= 80) {
      scoreColor = AppTheme.successColor;
      scoreLabel = '优秀';
    } else if (score >= 60) {
      scoreColor = AppTheme.warningColor;
      scoreLabel = '良好';
    } else if (score > 0) {
      scoreColor = AppTheme.errorColor;
      scoreLabel = '需改善';
    } else {
      scoreColor = Colors.grey;
      scoreLabel = '暂无';
    }

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              scoreColor.withOpacity(0.08),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // 健康评分环形图
            SizedBox(
              width: 85,
              height: 85,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 85,
                    height: 85,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        '分',
                        style: TextStyle(
                          fontSize: 11,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 健康状态文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scoreColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          scoreLabel,
                          style: TextStyle(
                            color: scoreColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_healthProfile == null)
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请在"我的"页面设置健康档案')),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 14),
                          label: const Text('设置档案', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getHealthSummary(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (_healthAnalysis?.recommendations.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            _healthAnalysis!.recommendations.first.advice,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHealthSummary() {
    if (_healthAnalysis == null) return '记录更多数据以获取健康评估';
    
    final bmi = _healthAnalysis!.bmiAnalysis;
    if (bmi != null) {
      return 'BMI ${bmi.bmi.toStringAsFixed(1)} (${bmi.label})';
    }
    return '继续保持健康的生活方式';
  }

  // 目标进度部分
  Widget _buildGoalProgressSection() {
    final progress = _todaySummary?.goalProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '今日目标',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  _todaySummary?.date ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 环形进度图网格
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularProgress(
                  icon: Icons.directions_walk,
                  label: '步数',
                  current: progress?.steps?.current ?? 0,
                  goal: progress?.steps?.goal ?? 10000,
                  color: HealthDataType.getColor('steps'),
                  unit: '步',
                ),
                _buildCircularProgress(
                  icon: Icons.water_drop,
                  label: '饮水',
                  current: progress?.water?.current ?? 0,
                  goal: progress?.water?.goal ?? 2500,
                  color: HealthDataType.getColor('water'),
                  unit: 'ml',
                ),
                _buildCircularProgress(
                  icon: Icons.bedtime,
                  label: '睡眠',
                  current: progress?.sleep?.current ?? 0,
                  goal: progress?.sleep?.goal ?? 8,
                  color: HealthDataType.getColor('sleep'),
                  unit: 'h',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress({
    required IconData icon,
    required String label,
    required double current,
    required double goal,
    required Color color,
    required String unit,
  }) {
    final percentage = goal > 0 ? (current / goal * 100).clamp(0, 100) : 0;
    
    return Column(
      children: [
        SizedBox(
          width: 65,
          height: 65,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 6,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 16),
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        Text(
          '${_formatValue(current, unit)}/${_formatValue(goal, unit)}',
          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
        ),
      ],
    );
  }

  String _formatValue(double value, String unit) {
    if (unit == 'h') {
      return value.toStringAsFixed(1);
    }
    return value.toInt().toString();
  }

  // 快速记录 - 水平滚动条
  Widget _buildQuickRecordSection() {
    final quickItems = [
      {'label': '体重', 'type': 'weight', 'icon': Icons.monitor_weight},
      {'label': '步数', 'type': 'steps', 'icon': Icons.directions_walk},
      {'label': '饮水', 'type': 'water', 'icon': Icons.water_drop},
      {'label': '睡眠', 'type': 'sleep', 'icon': Icons.bedtime},
      {'label': '心率', 'type': 'heart_rate', 'icon': Icons.favorite},
      {'label': '血压', 'type': 'blood_pressure_sys', 'icon': Icons.favorite_border},
      {'label': '热量', 'type': 'calories', 'icon': Icons.local_fire_department},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '快速记录',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddRecordScreen()),
                  );
                  if (result == true) _loadData();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('全部 >', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: quickItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = quickItems[index];
              return _buildQuickRecordChip(
                item['label'] as String,
                item['type'] as String,
                item['icon'] as IconData,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRecordChip(String label, String type, IconData icon) {
    final color = HealthDataType.getColor(type);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddRecordScreen(initialType: type),
          ),
        );
        if (result == true) _loadData();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 今日数据详情 - 紧凑网格布局
  Widget _buildTodayDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日数据',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompactDataItem(
                    icon: Icons.monitor_weight,
                    label: '体重',
                    value: _todaySummary?.summary['weight']?.value,
                    unit: 'kg',
                    color: HealthDataType.getColor('weight'),
                    decimals: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactDataItem(
                    icon: Icons.favorite,
                    label: '心率',
                    value: _todaySummary?.summary['heart_rate']?.value,
                    unit: 'bpm',
                    color: HealthDataType.getColor('heart_rate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildCompactDataItem(
                    icon: Icons.favorite_border,
                    label: '血压',
                    customValue: _getBloodPressure(),
                    unit: 'mmHg',
                    color: HealthDataType.getColor('blood_pressure_sys'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactDataItem(
                    icon: Icons.local_fire_department,
                    label: '热量',
                    value: _todaySummary?.summary['calories']?.value,
                    unit: 'kcal',
                    color: HealthDataType.getColor('calories'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDataItem({
    required IconData icon,
    required String label,
    double? value,
    String? customValue,
    required String unit,
    required Color color,
    int decimals = 0,
  }) {
    final displayValue = customValue ?? (value != null 
        ? (decimals > 0 ? value.toStringAsFixed(decimals) : value.toInt().toString())
        : '-');
    final hasValue = value != null || customValue != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: hasValue ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getBloodPressure() {
    final sys = _todaySummary?.summary['blood_pressure_sys']?.value;
    final dia = _todaySummary?.summary['blood_pressure_dia']?.value;
    if (sys != null && dia != null) {
      return '${sys.toInt()}/${dia.toInt()}';
    }
    return null;
  }

  // 每日贴士
  Widget _buildDailyTipCard() {
    return Card(
      color: AppTheme.primaryLight.withOpacity(0.06),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dailyTip!.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _dailyTip!.category,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dailyTip!.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
