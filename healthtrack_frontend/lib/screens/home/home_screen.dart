import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/today_summary_model.dart';
import '../../models/public_models.dart';
import '../../models/health_analysis_model.dart';
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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保 widget 树构建完成后再加载数据
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

      // 分开请求，避免一个失败导致全部失败
      try {
        _todaySummary = await authProvider.healthService.getTodaySummary();
      } catch (e) {
        debugPrint('获取今日概览失败: $e');
        // 不抛出异常，继续加载其他数据
      }

      try {
        _dailyTip = await authProvider.publicService.getDailyTip();
      } catch (e) {
        debugPrint('获取每日贴士失败: $e');
        // 不抛出异常
      }

      try {
        _healthAnalysis = await authProvider.healthService.getAnalysis();
      } catch (e) {
        debugPrint('获取健康分析失败: $e');
        // 不抛出异常
      }
    } catch (e) {
      debugPrint('加载数据异常: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text('你好，${user?.displayName ?? '用户'}'),
        actions: [
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 健康评分卡片
                    if (_healthAnalysis != null) ...[
                      _buildHealthScoreCard(),
                      const SizedBox(height: 16),
                    ],

                    // 今日概览卡片
                    _buildTodayOverviewCard(),
                    const SizedBox(height: 16),

                    // 目标进度（可视化环形图）
                    _buildGoalProgressSection(),
                    const SizedBox(height: 16),

                    // 快速记录
                    _buildQuickRecordSection(),
                    const SizedBox(height: 16),

                    // 每日贴士
                    if (_dailyTip != null) _buildDailyTipCard(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '今日概览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _todaySummary?.date ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem(
                  icon: Icons.directions_walk,
                  label: '步数',
                  value: _todaySummary?.summary['steps']?.value.toInt().toString() ?? '0',
                  color: HealthDataType.getColor('steps'),
                ),
                _buildOverviewItem(
                  icon: Icons.water_drop,
                  label: '饮水',
                  value: '${_todaySummary?.summary['water']?.value.toInt() ?? 0}ml',
                  color: HealthDataType.getColor('water'),
                ),
                _buildOverviewItem(
                  icon: Icons.bedtime,
                  label: '睡眠',
                  value: '${_todaySummary?.summary['sleep']?.value.toStringAsFixed(1) ?? '0'}h',
                  color: HealthDataType.getColor('sleep'),
                ),
                _buildOverviewItem(
                  icon: Icons.monitor_weight,
                  label: '体重',
                  value: '${_todaySummary?.summary['weight']?.value.toStringAsFixed(1) ?? '-'}kg',
                  color: HealthDataType.getColor('weight'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgressSection() {
    final progress = _todaySummary?.goalProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日目标',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // 环形进度图布局
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRadialProgressItem(
                  label: '步数',
                  current: progress?.steps?.current ?? 0,
                  goal: progress?.steps?.goal ?? 10000,
                  percentage: progress?.steps?.percentage ?? 0,
                  color: HealthDataType.getColor('steps'),
                  icon: Icons.directions_walk,
                  unit: '步',
                ),
                _buildRadialProgressItem(
                  label: '饮水',
                  current: progress?.water?.current ?? 0,
                  goal: progress?.water?.goal ?? 2500,
                  percentage: progress?.water?.percentage ?? 0,
                  color: HealthDataType.getColor('water'),
                  icon: Icons.water_drop,
                  unit: 'ml',
                ),
                _buildRadialProgressItem(
                  label: '睡眠',
                  current: progress?.sleep?.current ?? 0,
                  goal: progress?.sleep?.goal ?? 8,
                  percentage: progress?.sleep?.percentage ?? 0,
                  color: HealthDataType.getColor('sleep'),
                  icon: Icons.bedtime,
                  unit: 'h',
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 详细进度条
            _buildDetailedProgress(progress),
          ],
        ),
      ),
    );
  }

  // 环形进度项
  Widget _buildRadialProgressItem({
    required String label,
    required double current,
    required double goal,
    required double percentage,
    required Color color,
    required IconData icon,
    required String unit,
  }) {
    final displayValue = unit == 'h' 
        ? current.toStringAsFixed(1) 
        : current.toInt().toString();
    
    return Column(
      children: [
        SizedBox(
          width: 85,
          height: 85,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 环形进度
              SizedBox(
                width: 85,
                height: 85,
                child: CustomPaint(
                  painter: _RadialProgressPainter(
                    progress: (percentage / 100).clamp(0.0, 1.0),
                    progressColor: color,
                    backgroundColor: color.withOpacity(0.15),
                    strokeWidth: 8,
                  ),
                ),
              ),
              // 中心图标和百分比
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$displayValue$unit',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 详细进度（线性进度条）
  Widget _buildDetailedProgress(GoalProgress? progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildProgressItem(
            label: '步数',
            current: progress?.steps?.current ?? 0,
            goal: progress?.steps?.goal ?? 10000,
            percentage: progress?.steps?.percentage ?? 0,
            color: HealthDataType.getColor('steps'),
            unit: '步',
          ),
          const SizedBox(height: 12),
          _buildProgressItem(
            label: '饮水',
            current: progress?.water?.current ?? 0,
            goal: progress?.water?.goal ?? 2500,
            percentage: progress?.water?.percentage ?? 0,
            color: HealthDataType.getColor('water'),
            unit: 'ml',
          ),
          const SizedBox(height: 12),
          _buildProgressItem(
            label: '睡眠',
            current: progress?.sleep?.current ?? 0,
            goal: progress?.sleep?.goal ?? 8,
            percentage: progress?.sleep?.percentage ?? 0,
            color: HealthDataType.getColor('sleep'),
            unit: '小时',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String label,
    required double current,
    required double goal,
    required double percentage,
    required Color color,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${current.toInt()} / ${goal.toInt()} $unit',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (percentage / 100).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildQuickRecordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickRecordButton('体重', 'weight', Icons.monitor_weight),
                _buildQuickRecordButton('步数', 'steps', Icons.directions_walk),
                _buildQuickRecordButton('饮水', 'water', Icons.water_drop),
                _buildQuickRecordButton('睡眠', 'sleep', Icons.bedtime),
                _buildQuickRecordButton('心率', 'heart_rate', Icons.favorite),
                _buildQuickRecordButton('血压', 'blood_pressure_sys', Icons.favorite_border),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRecordButton(String label, String type, IconData icon) {
    final color = HealthDataType.getColor(type);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddRecordScreen(initialType: type),
          ),
        );
        if (result == true) {
          _loadData();
        }
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Card(
      color: AppTheme.primaryLight.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '今日健康贴士',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _dailyTip!.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _dailyTip!.content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 健康评分卡片 - 使用 fl_chart 环形图
  Widget _buildHealthScoreCard() {
    final score = _healthAnalysis!.healthScore;
    Color scoreColor;
    String scoreLabel;

    if (score >= 80) {
      scoreColor = AppTheme.successColor;
      scoreLabel = '优秀';
    } else if (score >= 60) {
      scoreColor = AppTheme.warningColor;
      scoreLabel = '良好';
    } else {
      scoreColor = AppTheme.errorColor;
      scoreLabel = '需改善';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '健康评分',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
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
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 0,
                      centerSpaceRadius: 55,
                      sections: [
                        PieChartSectionData(
                          value: score.toDouble(),
                          color: scoreColor,
                          radius: 20,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: (100 - score).toDouble(),
                          color: Colors.grey[200],
                          radius: 20,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        '分',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 评分说明
            _buildScoreBreakdown(),
          ],
        ),
      ),
    );
  }

  // 评分细分
  Widget _buildScoreBreakdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildScoreItem('BMI 指标', 20, Icons.fitness_center),
          const SizedBox(height: 8),
          _buildScoreItem('运动达标', 15, Icons.directions_walk),
          const SizedBox(height: 8),
          _buildScoreItem('睡眠质量', 10, Icons.bedtime),
          const SizedBox(height: 8),
          _buildScoreItem('心率血压', 10, Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int maxScore, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
        Text(
          '满分 $maxScore',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// 自定义环形进度绘制器
class _RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _RadialProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // 背景圆弧
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 进度圆弧
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
