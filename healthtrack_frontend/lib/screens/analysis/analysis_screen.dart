import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_analysis_model.dart';
import '../../models/health_record_model.dart';
import '../../models/health_profile_model.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HealthAnalysis? _analysis;
  TrendResponse? _trendData;
  PersonalizedHealthAnalysis? _personalizedAnalysis;
  bool _isLoading = true;
  bool _isTrendLoading = false;
  bool _isPersonalizedLoading = false;
  String? _trendError;
  String? _personalizedError;
  String _selectedTrendType = 'weight';
  String _selectedPeriod = 'month';  // 默认改为 month，数据更多

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 使用 addPostFrameCallback 确保 widget 树构建完成后再加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    try {
      final analysis = await authProvider.healthService.getAnalysis();
      if (mounted) {
        setState(() {
          _analysis = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载分析数据失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
    
    // 加载趋势数据
    await _loadTrend();
    
    // 加载个性化分析
    await _loadPersonalizedAnalysis();
  }

  Future<void> _loadPersonalizedAnalysis() async {
    if (!mounted) return;
    setState(() {
      _isPersonalizedLoading = true;
      _personalizedError = null;
    });

    final authProvider = context.read<AuthProvider>();
    try {
      final analysis = await authProvider.healthProfileService.getPersonalizedAnalysis();
      if (mounted) {
        setState(() {
          _personalizedAnalysis = analysis;
          _isPersonalizedLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载个性化分析失败: $e');
      if (mounted) {
        setState(() {
          _personalizedError = e.toString();
          _isPersonalizedLoading = false;
        });
      }
    }
  }

  Future<void> _loadTrend() async {
    if (!mounted) return;
    setState(() {
      _isTrendLoading = true;
      _trendError = null;
    });

    final authProvider = context.read<AuthProvider>();
    try {
      debugPrint('加载趋势数据: type=$_selectedTrendType, period=$_selectedPeriod');
      final trend = await authProvider.healthService.getTrends(
        _selectedTrendType,
        period: _selectedPeriod,
      );
      debugPrint('趋势数据响应: type=${trend.type}, data长度=${trend.data.length}');
      if (trend.data.isNotEmpty) {
        debugPrint('第一条数据: date=${trend.data.first.date}, value=${trend.data.first.value}');
      }
      if (mounted) {
        setState(() {
          _trendData = trend;
          _isTrendLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载趋势数据失败: $e');
      if (mounted) {
        setState(() {
          _trendError = e.toString();
          _isTrendLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康分析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '健康报告'),
            Tab(text: '趋势图表'),
            Tab(text: '个性化分析'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAnalysisTab(),
                _buildTrendsTab(),
                _buildPersonalizedTab(),
              ],
            ),
    );
  }

  Widget _buildAnalysisTab() {
    if (_analysis == null) {
      return const Center(child: Text('暂无数据'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 健康评分
            _buildHealthScoreCard(),
            const SizedBox(height: 16),

            // BMI 分析
            if (_analysis!.bmiAnalysis != null) ...[
              _buildBmiCard(),
              const SizedBox(height: 16),
            ],

            // 当前状态
            _buildCurrentStatusCard(),
            const SizedBox(height: 16),

            // 统计数据
            _buildStatisticsCard(),
            const SizedBox(height: 16),

            // 健康建议
            if (_analysis!.recommendations.isNotEmpty) _buildRecommendationsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final score = _analysis!.healthScore;
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '健康评分',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      scoreLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiCard() {
    final bmi = _analysis!.bmiAnalysis!;
    final progress = ((bmi.bmi - bmi.min) / (bmi.max - bmi.min)).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI 分析',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BMI: ${bmi.bmi.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getBmiColor(bmi.label).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bmi.label,
                    style: TextStyle(
                      color: _getBmiColor(bmi.label),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getBmiColor(bmi.label)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('偏瘦 (${bmi.min})', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text('正常', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text('偏胖 (${bmi.max})', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            if (bmi.advice != null) ...[
              const SizedBox(height: 12),
              Text(
                bmi.advice!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBmiColor(String label) {
    switch (label) {
      case '偏瘦':
        return Colors.blue;
      case '正常':
        return AppTheme.successColor;
      case '超重':
        return AppTheme.warningColor;
      case '肥胖':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCurrentStatusCard() {
    final status = _analysis!.currentStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前状态',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                if (status.weight != null)
                  _buildStatusItem('体重', '${status.weight}kg', 'weight'),
                if (status.steps != null)
                  _buildStatusItem('步数', '${status.steps}', 'steps'),
                if (status.heartRate != null)
                  _buildStatusItem('心率', '${status.heartRate}bpm', 'heart_rate'),
                if (status.bloodPressure != null)
                  _buildStatusItem('血压', status.bloodPressure!, 'blood_pressure_sys'),
                if (status.sleep != null)
                  _buildStatusItem('睡眠', '${status.sleep}h', 'sleep'),
                if (status.water != null)
                  _buildStatusItem('饮水', '${status.water}ml', 'water'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, String type) {
    final color = HealthDataType.getColor(type);
    final icon = HealthDataType.getIcon(type);

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
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
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final weekly = _analysis!.statistics.weekly;
    final monthly = _analysis!.statistics.monthly;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '统计数据',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (weekly != null) ...[
              const Text('本周', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('日均步数', '${weekly.avgSteps.toInt()}'),
                  _buildStatItem('总步数', '${weekly.totalSteps}'),
                  _buildStatItem('平均体重', '${weekly.avgWeight.toStringAsFixed(1)}kg'),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (monthly != null) ...[
              const Text('本月', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('日均步数', '${monthly.avgSteps.toInt()}'),
                  _buildStatItem('总步数', '${monthly.totalSteps}'),
                  if (monthly.weightChange != null)
                    _buildStatItem(
                      '体重变化',
                      '${monthly.weightChange! > 0 ? '+' : ''}${monthly.weightChange!.toStringAsFixed(1)}kg',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Widget _buildRecommendationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '健康建议',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._analysis!.recommendations.map((rec) => _buildRecommendationItem(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Recommendation rec) {
    Color priorityColor;
    IconData priorityIcon;

    switch (rec.priority) {
      case 'high':
        priorityColor = AppTheme.errorColor;
        priorityIcon = Icons.warning;
        break;
      case 'medium':
        priorityColor = AppTheme.warningColor;
        priorityIcon = Icons.info;
        break;
      default:
        priorityColor = AppTheme.infoColor;
        priorityIcon = Icons.lightbulb;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(priorityIcon, color: priorityColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.category,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: priorityColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.advice,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return Column(
      children: [
        // 筛选栏
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTrendType,
                  decoration: const InputDecoration(
                    labelText: '数据类型',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'weight', child: Text('体重')),
                    DropdownMenuItem(value: 'steps', child: Text('步数')),
                    DropdownMenuItem(value: 'heart_rate', child: Text('心率')),
                    DropdownMenuItem(value: 'sleep', child: Text('睡眠')),
                    DropdownMenuItem(value: 'water', child: Text('饮水')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTrendType = value);
                      _loadTrend();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: '时间范围',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'week', child: Text('近一周')),
                    DropdownMenuItem(value: 'month', child: Text('近一月')),
                    DropdownMenuItem(value: 'quarter', child: Text('近三月')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriod = value);
                      _loadTrend();
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // 图表
        Expanded(
          child: _buildTrendContent(),
        ),
      ],
    );
  }

  Widget _buildTrendContent() {
    if (_isTrendLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_trendError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('加载失败', style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 8),
            Text(
              _trendError!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrend,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_trendData == null || _trendData!.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('暂无趋势数据'),
            const SizedBox(height: 8),
            Text(
              '请先添加一些${_getTypeName(_selectedTrendType)}记录',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 统计摘要
          _buildTrendSummary(),
          const SizedBox(height: 16),
          // 图表
          Expanded(child: _buildTrendChart()),
        ],
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'weight': return '体重';
      case 'steps': return '步数';
      case 'heart_rate': return '心率';
      case 'sleep': return '睡眠';
      case 'water': return '饮水';
      default: return type;
    }
  }

  Widget _buildTrendSummary() {
    final data = _trendData!.data;
    final values = data.map((e) => e.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('平均', avg.toStringAsFixed(1)),
            _buildSummaryItem('最低', min.toStringAsFixed(1)),
            _buildSummaryItem('最高', max.toStringAsFixed(1)),
            _buildSummaryItem('记录数', '${data.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
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

  Widget _buildTrendChart() {
    final data = _trendData!.data;
    final color = HealthDataType.getColor(_selectedTrendType);

    // 计算Y轴范围
    double minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    // 如果最大最小相同，添加一些范围
    if (minY == maxY) {
      minY = minY * 0.9;
      maxY = maxY * 1.1;
      if (minY == 0) {
        minY = 0;
        maxY = 10;
      }
    }
    
    final padding = (maxY - minY) * 0.1;
    minY = (minY - padding).clamp(0, double.infinity);
    maxY = maxY + padding;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  _selectedTrendType == 'steps' 
                      ? value.toInt().toString()
                      : value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (data.length / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      date.length >= 10 ? date.substring(5, 10) : date, // MM-DD
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i].value),
            ),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: data.length <= 15,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.spotIndex;
                final point = data[index];
                return LineTooltipItem(
                  '${point.date}\n${point.value.toStringAsFixed(1)} ${HealthDataType.getUnit(_selectedTrendType)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // ================= 个性化分析 Tab =================
  
  Widget _buildPersonalizedTab() {
    if (_isPersonalizedLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_personalizedError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              '请先设置个人健康档案',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '在"我的"页面中设置您的健康档案，\n获取个性化健康分析',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPersonalizedAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_personalizedAnalysis == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('暂无个性化分析数据'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPersonalizedAnalysis,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 个性化评分
            _buildPersonalizedScoreCard(),
            const SizedBox(height: 16),

            // 雷达图
            _buildRadarChartCard(),
            const SizedBox(height: 16),

            // 个性化标准
            _buildPersonalizedStandardsCard(),
            const SizedBox(height: 16),

            // 指标详情
            _buildMetricsAnalysisCard(),
            const SizedBox(height: 16),

            // 个性化建议
            if (_personalizedAnalysis!.recommendations.isNotEmpty)
              _buildPersonalizedRecommendationsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedScoreCard() {
    final score = _personalizedAnalysis!.overallScore ?? 0;
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '个性化健康评分',
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: score.toDouble(),
                          color: scoreColor,
                          radius: 18,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: (100 - score).toDouble(),
                          color: Colors.grey[200],
                          radius: 18,
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
                          fontSize: 36,
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
            Text(
              '基于您的个人健康档案计算',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChartCard() {
    final metrics = _personalizedAnalysis!.metricsAnalysis;
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
    }

    // 准备雷达图数据
    final radarData = _prepareRadarData(metrics);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.radar, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  '健康指标雷达图',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '各项指标达标程度可视化',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  getTitle: (index, angle) {
                    if (index < radarData.length) {
                      return RadarChartTitle(
                        text: radarData[index]['label'] as String,
                      );
                    }
                    return const RadarChartTitle(text: '');
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppTheme.primaryColor.withOpacity(0.2),
                      borderColor: AppTheme.primaryColor,
                      borderWidth: 2,
                      entryRadius: 4,
                      dataEntries: radarData
                          .map((item) => RadarEntry(value: item['value'] as double))
                          .toList(),
                    ),
                  ],
                  tickCount: 4,
                  ticksTextStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  tickBorderData: BorderSide(color: Colors.grey[300]!),
                  gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 图例
            _buildRadarLegend(radarData),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _prepareRadarData(List<HealthMetricAnalysis> metrics) {
    final List<Map<String, dynamic>> data = [];
    
    for (final metric in metrics) {
      String label;
      double value = 0;
      
      // 根据状态计算达标程度
      switch (metric.status) {
        case 'good':
          value = 100;
          break;
        case 'warning':
          value = 60;
          break;
        case 'alert':
          value = 30;
          break;
        default:
          value = 50;
      }
      
      // 获取指标中文名
      switch (metric.metric) {
        case 'steps':
          label = '步数';
          break;
        case 'heart_rate':
          label = '心率';
          break;
        case 'sleep':
          label = '睡眠';
          break;
        case 'water':
          label = '饮水';
          break;
        case 'bmi':
          label = 'BMI';
          break;
        case 'blood_pressure':
          label = '血压';
          break;
        default:
          label = metric.metric;
      }
      
      data.add({
        'label': label,
        'value': value,
        'status': metric.status,
        'metric': metric.metric,
      });
    }
    
    return data;
  }

  Widget _buildRadarLegend(List<Map<String, dynamic>> radarData) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: radarData.map((item) {
        Color statusColor;
        switch (item['status']) {
          case 'good':
            statusColor = AppTheme.successColor;
            break;
          case 'warning':
            statusColor = AppTheme.warningColor;
            break;
          case 'alert':
            statusColor = AppTheme.errorColor;
            break;
          default:
            statusColor = Colors.grey;
        }
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item['label'] as String,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPersonalizedStandardsCard() {
    final standards = _personalizedAnalysis!.personalizedStandards;
    if (standards == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_ind, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  '您的个性化标准',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildProfileInfo(standards),
            const Divider(height: 24),
            _buildStandardsList(standards),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(PersonalizedHealthStandards standards) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: AppTheme.primaryColor, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standards.username ?? '用户',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (standards.ageGroup != null)
                      _buildInfoChip(_getAgeGroupDisplay(standards.ageGroup!)),
                    if (standards.activityLevel != null)
                      _buildInfoChip(_getActivityLevelDisplay(standards.activityLevel!)),
                    if (standards.gender != null)
                      _buildInfoChip(standards.gender == 'male' ? '男' : '女'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  String _getAgeGroupDisplay(String ageGroup) {
    switch (ageGroup) {
      case 'child': return '儿童';
      case 'teen': return '青少年';
      case 'adult': return '成人';
      case 'middle_age': return '中年';
      case 'senior': return '老年';
      default: return ageGroup;
    }
  }

  String _getActivityLevelDisplay(String level) {
    switch (level) {
      case 'sedentary': return '久坐';
      case 'lightly_active': return '轻度活动';
      case 'moderately_active': return '中等活动';
      case 'very_active': return '高度活动';
      case 'extremely_active': return '极高活动';
      default: return level;
    }
  }

  Widget _buildStandardsList(PersonalizedHealthStandards standards) {
    return Column(
      children: [
        if (standards.recommendedDailySteps != null)
          _buildStandardItem(
            icon: Icons.directions_walk,
            label: '每日步数目标',
            value: '${standards.recommendedDailySteps} 步',
            color: HealthDataType.getColor('steps'),
          ),
        if (standards.recommendedHeartRateMin != null && standards.recommendedHeartRateMax != null)
          _buildStandardItem(
            icon: Icons.favorite,
            label: '心率正常范围',
            value: '${standards.recommendedHeartRateMin}-${standards.recommendedHeartRateMax} bpm',
            color: HealthDataType.getColor('heart_rate'),
          ),
        if (standards.recommendedSleepHours != null)
          _buildStandardItem(
            icon: Icons.bedtime,
            label: '建议睡眠时长',
            value: '${standards.recommendedSleepHours} 小时',
            color: HealthDataType.getColor('sleep'),
          ),
        if (standards.recommendedWaterMl != null)
          _buildStandardItem(
            icon: Icons.water_drop,
            label: '每日饮水目标',
            value: '${standards.recommendedWaterMl} ml',
            color: HealthDataType.getColor('water'),
          ),
        if (standards.bmiOptimalMin != null && standards.bmiOptimalMax != null)
          _buildStandardItem(
            icon: Icons.monitor_weight,
            label: 'BMI理想范围',
            value: '${standards.bmiOptimalMin!.toStringAsFixed(1)}-${standards.bmiOptimalMax!.toStringAsFixed(1)}',
            color: HealthDataType.getColor('weight'),
          ),
        // 血压: 优先使用原始字符串，否则用解析的数值
        if (standards.bloodPressureNormalString != null && 
            standards.bloodPressureNormalString!.isNotEmpty &&
            !standards.bloodPressureNormalString!.contains('null'))
          _buildStandardItem(
            icon: Icons.favorite_border,
            label: '血压正常值',
            value: standards.bloodPressureNormalString!,
            color: HealthDataType.getColor('blood_pressure_sys'),
          )
        else if (standards.bloodPressureSystolicNormal != null && 
                 standards.bloodPressureDiastolicNormal != null)
          _buildStandardItem(
            icon: Icons.favorite_border,
            label: '血压正常值',
            value: '${standards.bloodPressureSystolicNormal}/${standards.bloodPressureDiastolicNormal} mmHg',
            color: HealthDataType.getColor('blood_pressure_sys'),
          ),
      ],
    );
  }

  Widget _buildStandardItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsAnalysisCard() {
    final metrics = _personalizedAnalysis!.metricsAnalysis;
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  '各项指标详情',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...metrics.map((metric) => _buildMetricAnalysisItem(metric)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricAnalysisItem(HealthMetricAnalysis metric) {
    Color statusColor;
    IconData statusIcon;

    switch (metric.status) {
      case 'good':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.warning;
        break;
      case 'alert':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    String metricLabel;
    String metricUnit = '';
    switch (metric.metric) {
      case 'steps':
        metricLabel = '步数';
        metricUnit = '步';
        break;
      case 'heart_rate':
        metricLabel = '心率';
        metricUnit = 'bpm';
        break;
      case 'sleep':
        metricLabel = '睡眠';
        metricUnit = '小时';
        break;
      case 'water':
        metricLabel = '饮水';
        metricUnit = 'ml';
        break;
      case 'bmi':
        metricLabel = 'BMI';
        break;
      case 'blood_pressure':
        metricLabel = '血压';
        metricUnit = 'mmHg';
        break;
      default:
        metricLabel = metric.metric;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                metricLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  metric.statusDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '当前: ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '${metric.currentValue ?? '-'} $metricUnit',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                '建议: ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                metric.recommendedDisplay ?? '${metric.recommendedMin ?? '-'} - ${metric.recommendedMax ?? '-'} $metricUnit',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          if (metric.advice != null) ...[
            const SizedBox(height: 8),
            Text(
              metric.advice!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.accentColor),
                SizedBox(width: 8),
                Text(
                  '个性化健康建议',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._personalizedAnalysis!.recommendations
                .map((rec) => _buildPersonalizedRecItem(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedRecItem(PersonalizedRecommendation rec) {
    Color priorityColor;
    IconData priorityIcon;

    switch (rec.priority) {
      case 'high':
        priorityColor = AppTheme.errorColor;
        priorityIcon = Icons.warning;
        break;
      case 'medium':
        priorityColor = AppTheme.warningColor;
        priorityIcon = Icons.info;
        break;
      default:
        priorityColor = AppTheme.infoColor;
        priorityIcon = Icons.lightbulb_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(priorityIcon, color: priorityColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rec.category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                        fontSize: 13,
                      ),
                    ),
                    if (rec.basedOn != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '基于: ${rec.basedOn}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rec.advice,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
