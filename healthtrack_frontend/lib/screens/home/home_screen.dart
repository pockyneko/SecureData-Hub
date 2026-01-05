import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/today_summary_model.dart';
import '../../models/public_models.dart';
import '../records/add_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TodaySummary? _todaySummary;
  HealthTip? _dailyTip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    try {
      final results = await Future.wait([
        authProvider.healthService.getTodaySummary(),
        authProvider.publicService.getDailyTip(),
      ]);

      if (mounted) {
        setState(() {
          _todaySummary = results[0] as TodaySummary;
          _dailyTip = results[1] as HealthTip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                    // 今日概览卡片
                    _buildTodayOverviewCard(),
                    const SizedBox(height: 16),

                    // 目标进度
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
            const SizedBox(height: 16),
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
}
