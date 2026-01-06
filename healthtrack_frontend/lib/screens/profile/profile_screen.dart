import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_analysis_model.dart';
import '../../models/health_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  HealthGoals? _goals;
  UserHealthProfile? _healthProfile;
  PersonalizedHealthStandards? _personalizedStandards;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      
      // 并行加载数据
      await Future.wait([
        _loadGoals(authProvider),
        _loadHealthProfile(authProvider),
        _loadPersonalizedStandards(authProvider),
      ]);
    } catch (e) {
      debugPrint('加载数据失败: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGoals(AuthProvider authProvider) async {
    try {
      final goals = await authProvider.healthService.getGoals();
      if (mounted) {
        setState(() => _goals = goals);
      }
    } catch (e) {
      debugPrint('加载目标失败: $e');
    }
  }

  Future<void> _loadHealthProfile(AuthProvider authProvider) async {
    try {
      final profile = await authProvider.healthProfileService.getProfile();
      if (mounted) {
        setState(() => _healthProfile = profile);
      }
    } catch (e) {
      debugPrint('加载健康档案失败: $e');
    }
  }

  Future<void> _loadPersonalizedStandards(AuthProvider authProvider) async {
    try {
      final standards = await authProvider.healthProfileService.getPersonalizedStandards();
      if (mounted) {
        setState(() => _personalizedStandards = standards);
      }
    } catch (e) {
      debugPrint('加载个性化标准失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
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
                  children: [
                    // 用户信息卡片
                    _buildUserCard(user),
                    const SizedBox(height: 16),

                    // 健康档案卡片
                    _buildHealthProfileCard(),
                    const SizedBox(height: 16),

                    // 个性化标准卡片
                    if (_personalizedStandards != null) ...[
                      _buildPersonalizedStandardsCard(),
                      const SizedBox(height: 16),
                    ],

                    // 健康目标卡片
                    _buildGoalsCard(),
                    const SizedBox(height: 16),

                    // 设置菜单
                    _buildSettingsMenu(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHealthProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_information, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      '健康档案',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showEditHealthProfileDialog(),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(_healthProfile != null ? '编辑' : '创建'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_healthProfile != null) ...[
              _buildProfileItem('年龄段', _healthProfile!.ageGroup?.displayName ?? '-'),
              _buildProfileItem('活动水平', _healthProfile!.activityLevel?.displayName ?? '-'),
              _buildProfileItem('健康状态', _healthProfile!.healthCondition?.displayName ?? '-'),
              if (_healthProfile!.hasCardiovascularIssues ||
                  _healthProfile!.hasDiabetes ||
                  _healthProfile!.hasJointIssues ||
                  _healthProfile!.isPregnant ||
                  _healthProfile!.isRecovering) ...[
                const Divider(),
                const Text('特殊情况:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (_healthProfile!.hasCardiovascularIssues)
                      _buildTag('心血管问题', Colors.red),
                    if (_healthProfile!.hasDiabetes)
                      _buildTag('糖尿病', Colors.orange),
                    if (_healthProfile!.hasJointIssues)
                      _buildTag('关节问题', Colors.blue),
                    if (_healthProfile!.isPregnant)
                      _buildTag('孕期', Colors.pink),
                    if (_healthProfile!.isRecovering)
                      _buildTag('康复期', Colors.green),
                  ],
                ),
              ],
              if (_healthProfile!.doctorNotes != null && _healthProfile!.doctorNotes!.isNotEmpty) ...[
                const Divider(),
                const Text('医生建议:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  _healthProfile!.doctorNotes!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '还未创建健康档案，创建后可获得个性化的健康标准和建议',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPersonalizedStandardsCard() {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '个性化健康标准',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStandardItem(
              Icons.directions_walk,
              '每日步数',
              '${_personalizedStandards!.recommendedDailySteps ?? '-'} 步',
              HealthDataType.getColor('steps'),
            ),
            _buildStandardItem(
              Icons.favorite,
              '目标心率',
              '${_personalizedStandards!.recommendedHeartRateMin ?? '-'} - ${_personalizedStandards!.recommendedHeartRateMax ?? '-'} bpm',
              HealthDataType.getColor('heart_rate'),
            ),
            _buildStandardItem(
              Icons.bedtime,
              '睡眠时长',
              '${_personalizedStandards!.recommendedSleepHours ?? '-'} 小时',
              HealthDataType.getColor('sleep'),
            ),
            _buildStandardItem(
              Icons.water_drop,
              '饮水量',
              '${_personalizedStandards!.recommendedWaterMl ?? '-'} ml',
              HealthDataType.getColor('water'),
            ),
            _buildStandardItem(
              Icons.monitor_weight,
              'BMI 范围',
              '${_personalizedStandards!.bmiOptimalMin?.toStringAsFixed(1) ?? '-'} - ${_personalizedStandards!.bmiOptimalMax?.toStringAsFixed(1) ?? '-'}',
              HealthDataType.getColor('weight'),
            ),
            _buildStandardItem(
              Icons.favorite_border,
              '血压标准',
              '${_personalizedStandards!.bloodPressureSystolicNormal ?? '-'}/${_personalizedStandards!.bloodPressureDiastolicNormal ?? '-'} mmHg',
              HealthDataType.getColor('blood_pressure_sys'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardItem(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
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

  Widget _buildUserCard(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 头像
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: user?.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        user!.avatar!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultAvatar(user?.displayName ?? ''),
                      ),
                    )
                  : _buildDefaultAvatar(user?.displayName ?? '用户'),
            ),
            const SizedBox(height: 16),

            // 昵称
            Text(
              user?.displayName ?? '用户',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // 邮箱
            Text(
              user?.email ?? '',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // 用户信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem('身高', '${user?.height ?? '-'} cm'),
                _buildInfoItem('性别', user?.genderDisplay ?? '-'),
                _buildInfoItem('生日', user?.birthday ?? '-'),
              ],
            ),
            const SizedBox(height: 16),

            // 编辑按钮
            OutlinedButton.icon(
              onPressed: () => _showEditProfileDialog(),
              icon: const Icon(Icons.edit),
              label: const Text('编辑资料'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildGoalsCard() {
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
                  '健康目标',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditGoalsDialog(),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('编辑'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGoalItem(
              icon: Icons.directions_walk,
              label: '每日步数',
              value: '${_goals?.stepsGoal ?? 10000}',
              unit: '步',
              color: HealthDataType.getColor('steps'),
            ),
            _buildGoalItem(
              icon: Icons.water_drop,
              label: '每日饮水',
              value: '${_goals?.waterGoal ?? 2500}',
              unit: 'ml',
              color: HealthDataType.getColor('water'),
            ),
            _buildGoalItem(
              icon: Icons.bedtime,
              label: '每日睡眠',
              value: '${_goals?.sleepGoal ?? 8}',
              unit: '小时',
              color: HealthDataType.getColor('sleep'),
            ),
            _buildGoalItem(
              icon: Icons.local_fire_department,
              label: '每日热量',
              value: '${_goals?.caloriesGoal ?? 2200}',
              unit: 'kcal',
              color: HealthDataType.getColor('calories'),
            ),
            if (_goals?.weightGoal != null)
              _buildGoalItem(
                icon: Icons.monitor_weight,
                label: '目标体重',
                value: '${_goals!.weightGoal}',
                unit: 'kg',
                color: HealthDataType.getColor('weight'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
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
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            '$value $unit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Card(
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.analytics,
            title: '个性化健康分析',
            onTap: () => _showPersonalizedAnalysisDialog(),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.lock,
            title: '修改密码',
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.auto_awesome,
            title: '生成模拟数据',
            onTap: () => _showGenerateMockDataDialog(),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.info,
            title: '关于应用',
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  void _showEditHealthProfileDialog() {
    AgeGroup? selectedAgeGroup = _healthProfile?.ageGroup;
    ActivityLevel selectedActivityLevel = _healthProfile?.activityLevel ?? ActivityLevel.moderatelyActive;
    HealthCondition selectedHealthCondition = _healthProfile?.healthCondition ?? HealthCondition.good;
    bool hasCardiovascularIssues = _healthProfile?.hasCardiovascularIssues ?? false;
    bool hasDiabetes = _healthProfile?.hasDiabetes ?? false;
    bool hasJointIssues = _healthProfile?.hasJointIssues ?? false;
    bool isPregnant = _healthProfile?.isPregnant ?? false;
    bool isRecovering = _healthProfile?.isRecovering ?? false;
    final doctorNotesController = TextEditingController(text: _healthProfile?.doctorNotes ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(_healthProfile != null ? '编辑健康档案' : '创建健康档案'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<AgeGroup>(
                    value: selectedAgeGroup,
                    decoration: const InputDecoration(
                      labelText: '年龄段 *',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    items: AgeGroup.values.map((group) => DropdownMenuItem(
                      value: group,
                      child: Text(group.displayName),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedAgeGroup = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ActivityLevel>(
                    value: selectedActivityLevel,
                    decoration: const InputDecoration(
                      labelText: '活动水平',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    items: ActivityLevel.values.map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.displayName),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedActivityLevel = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<HealthCondition>(
                    value: selectedHealthCondition,
                    decoration: const InputDecoration(
                      labelText: '健康状态',
                      prefixIcon: Icon(Icons.health_and_safety),
                    ),
                    items: HealthCondition.values.map((condition) => DropdownMenuItem(
                      value: condition,
                      child: Text(condition.displayName),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedHealthCondition = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('特殊情况（可选）:', style: TextStyle(fontWeight: FontWeight.w500)),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('心血管问题'),
                    value: hasCardiovascularIssues,
                    onChanged: (value) {
                      setDialogState(() => hasCardiovascularIssues = value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('糖尿病'),
                    value: hasDiabetes,
                    onChanged: (value) {
                      setDialogState(() => hasDiabetes = value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('关节问题'),
                    value: hasJointIssues,
                    onChanged: (value) {
                      setDialogState(() => hasJointIssues = value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('孕期'),
                    value: isPregnant,
                    onChanged: (value) {
                      setDialogState(() => isPregnant = value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('康复期'),
                    value: isRecovering,
                    onChanged: (value) {
                      setDialogState(() => isRecovering = value ?? false);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: doctorNotesController,
                    decoration: const InputDecoration(
                      labelText: '医生建议（可选）',
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedAgeGroup == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请选择年龄段')),
                    );
                    return;
                  }

                  final profile = UserHealthProfile(
                    ageGroup: selectedAgeGroup,
                    activityLevel: selectedActivityLevel,
                    healthCondition: selectedHealthCondition,
                    hasCardiovascularIssues: hasCardiovascularIssues,
                    hasDiabetes: hasDiabetes,
                    hasJointIssues: hasJointIssues,
                    isPregnant: isPregnant,
                    isRecovering: isRecovering,
                    doctorNotes: doctorNotesController.text.trim().isNotEmpty
                        ? doctorNotesController.text.trim()
                        : null,
                  );

                  try {
                    final authProvider = context.read<AuthProvider>();
                    final savedProfile = await authProvider.healthProfileService.saveProfile(profile);
                    
                    if (mounted) {
                      setState(() => _healthProfile = savedProfile);
                      Navigator.pop(context);
                      
                      // 重新加载个性化标准
                      _loadPersonalizedStandards(authProvider);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('健康档案保存成功')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('保存失败: $e')),
                      );
                    }
                  }
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPersonalizedAnalysisDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authProvider = context.read<AuthProvider>();
      final analysis = await authProvider.healthProfileService.getPersonalizedAnalysis();
      
      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框
        _showAnalysisResultDialog(analysis);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取分析失败: $e')),
        );
      }
    }
  }

  void _showAnalysisResultDialog(PersonalizedHealthAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('个性化健康分析'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 健康评分
              if (analysis.overallScore != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getScoreColor(analysis.overallScore!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${analysis.overallScore}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(analysis.overallScore!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '分\n${_getScoreLabel(analysis.overallScore!)}',
                        style: TextStyle(
                          color: _getScoreColor(analysis.overallScore!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 指标分析
              if (analysis.metricsAnalysis.isNotEmpty) ...[
                const Text('指标分析:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...analysis.metricsAnalysis.map((metric) => _buildMetricAnalysisItem(metric)),
              ],

              // 建议
              if (analysis.recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('个性化建议:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...analysis.recommendations.map((rec) => _buildRecommendationItem(rec)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return '优秀';
    if (score >= 60) return '良好';
    return '需改善';
  }

  Widget _buildMetricAnalysisItem(HealthMetricAnalysis metric) {
    Color statusColor;
    switch (metric.status) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.metric, style: const TextStyle(fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  metric.statusDisplay,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
          if (metric.advice != null) ...[
            const SizedBox(height: 4),
            Text(
              metric.advice!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(PersonalizedRecommendation rec) {
    Color priorityColor;
    switch (rec.priority) {
      case 'high':
        priorityColor = AppTheme.errorColor;
        break;
      case 'medium':
        priorityColor = AppTheme.warningColor;
        break;
      default:
        priorityColor = AppTheme.successColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: priorityColor, size: 20),
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
                Text(
                  rec.advice,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final user = context.read<AuthProvider>().user;
    final nicknameController = TextEditingController(text: user?.nickname);
    final heightController = TextEditingController(
      text: user?.height?.toString() ?? '',
    );
    String gender = user?.gender ?? 'male';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('编辑资料'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nicknameController,
                    decoration: const InputDecoration(
                      labelText: '昵称',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: heightController,
                    decoration: const InputDecoration(
                      labelText: '身高 (cm)',
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(
                      labelText: '性别',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('男')),
                      DropdownMenuItem(value: 'female', child: Text('女')),
                      DropdownMenuItem(value: 'other', child: Text('其他')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => gender = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await context.read<AuthProvider>().updateProfile(
                    nickname: nicknameController.text.trim().isNotEmpty
                        ? nicknameController.text.trim()
                        : null,
                    height: heightController.text.isNotEmpty
                        ? double.tryParse(heightController.text)
                        : null,
                    gender: gender,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('资料更新成功')),
                    );
                  }
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditGoalsDialog() {
    final stepsController = TextEditingController(
      text: _goals?.stepsGoal.toString() ?? '10000',
    );
    final waterController = TextEditingController(
      text: _goals?.waterGoal.toString() ?? '2500',
    );
    final sleepController = TextEditingController(
      text: _goals?.sleepGoal.toString() ?? '8',
    );
    final caloriesController = TextEditingController(
      text: _goals?.caloriesGoal.toString() ?? '2200',
    );
    final weightController = TextEditingController(
      text: _goals?.weightGoal?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑健康目标'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(
                  labelText: '每日步数目标',
                  suffixText: '步',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waterController,
                decoration: const InputDecoration(
                  labelText: '每日饮水目标',
                  suffixText: 'ml',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sleepController,
                decoration: const InputDecoration(
                  labelText: '每日睡眠目标',
                  suffixText: '小时',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: '每日热量目标',
                  suffixText: 'kcal',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: '目标体重（可选）',
                  suffixText: 'kg',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newGoals = HealthGoals(
                stepsGoal: int.tryParse(stepsController.text) ?? 10000,
                waterGoal: int.tryParse(waterController.text) ?? 2500,
                sleepGoal: double.tryParse(sleepController.text) ?? 8,
                caloriesGoal: int.tryParse(caloriesController.text) ?? 2200,
                weightGoal: weightController.text.isNotEmpty
                    ? double.tryParse(weightController.text)
                    : null,
              );

              try {
                final authProvider = context.read<AuthProvider>();
                await authProvider.healthService.updateGoals(newGoals);
                if (mounted) {
                  setState(() => _goals = newGoals);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('目标更新成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更新失败: $e')),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '当前密码',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '新密码',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认新密码',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('两次密码输入不一致')),
                );
                return;
              }

              final success = await context.read<AuthProvider>().changePassword(
                oldPassword: oldPasswordController.text,
                newPassword: newPasswordController.text,
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密码修改成功')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<AuthProvider>().error ?? '修改失败'),
                  ),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showGenerateMockDataDialog() {
    int days = 30;
    bool demoMode = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('生成模拟数据'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('生成最近几天的模拟健康数据，方便体验功能。'),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: days,
                  decoration: const InputDecoration(
                    labelText: '天数',
                  ),
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('7天')),
                    DropdownMenuItem(value: 14, child: Text('14天')),
                    DropdownMenuItem(value: 30, child: Text('30天')),
                    DropdownMenuItem(value: 60, child: Text('60天')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => days = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('演示模式'),
                  subtitle: const Text('数据趋势更明显'),
                  value: demoMode,
                  onChanged: (value) {
                    setDialogState(() => demoMode = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('正在生成模拟数据...')),
                  );

                  try {
                    final authProvider = context.read<AuthProvider>();
                    final result = await authProvider.healthService.generateMockData(
                      days: days,
                      demoMode: demoMode,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('成功生成 ${result.insertedCount} 条数据'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('生成失败: $e')),
                      );
                    }
                  }
                },
                child: const Text('生成'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 HealthTrack'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('HealthTrack 是一款全面的健康管理应用，帮助您追踪和分析各项健康指标。'),
            SizedBox(height: 8),
            Text('功能包括：'),
            Text('• 记录体重、步数、心率、血压等健康数据'),
            Text('• 查看健康趋势和分析报告'),
            Text('• 设置个人健康目标'),
            Text('• 获取健康知识和建议'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
