import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/public_models.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _categories = [];
  List<HealthTip> _tips = [];
  ExerciseRecommendationsResponse? _exercises;
  bool _isLoading = true;
  String? _selectedCategory;

  // 运动推荐筛选
  String _weather = 'sunny';
  String _timeSlot = 'morning';

  final List<Map<String, String>> _weatherOptions = [
    {'value': 'sunny', 'label': '晴天'},
    {'value': 'cloudy', 'label': '阴天'},
    {'value': 'rainy', 'label': '雨天'},
    {'value': 'hot', 'label': '炎热'},
    {'value': 'cold', 'label': '寒冷'},
  ];

  final List<Map<String, String>> _timeSlotOptions = [
    {'value': 'morning', 'label': '早晨'},
    {'value': 'afternoon', 'label': '下午'},
    {'value': 'evening', 'label': '傍晚'},
    {'value': 'night', 'label': '夜间'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    final publicService = context.read<AuthProvider>().publicService;

    // 分开请求，避免一个失败导致全部失败
    try {
      _categories = await publicService.getTipCategories();
    } catch (e) {
      debugPrint('加载分类失败: $e');
    }

    try {
      _tips = await publicService.getTips(category: _selectedCategory);
    } catch (e) {
      debugPrint('加载健康百科失败: $e');
    }

    try {
      _exercises = await publicService.getExerciseRecommendations(
        weather: _weather,
        timeSlot: _timeSlot,
      );
    } catch (e) {
      debugPrint('加载运动推荐失败: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTips() async {
    final publicService = context.read<AuthProvider>().publicService;
    try {
      final tips = await publicService.getTips(category: _selectedCategory);
      if (mounted) {
        setState(() => _tips = tips);
      }
    } catch (e) {
      debugPrint('加载健康百科失败: $e');
    }
  }

  Future<void> _loadExercises() async {
    final publicService = context.read<AuthProvider>().publicService;
    try {
      final exercises = await publicService.getExerciseRecommendations(
        weather: _weather,
        timeSlot: _timeSlot,
      );
      if (mounted) {
        setState(() => _exercises = exercises);
      }
    } catch (e) {
      // 忽略错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康百科'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '健康知识'),
            Tab(text: '运动推荐'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTipsTab(),
                _buildExercisesTab(),
              ],
            ),
    );
  }

  Widget _buildTipsTab() {
    return Column(
      children: [
        // 分类筛选
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(null, '全部'),
              ..._categories.map((cat) => _buildCategoryChip(cat, cat)),
            ],
          ),
        ),

        // 文章列表
        Expanded(
          child: _tips.isEmpty
              ? const Center(child: Text('暂无内容'))
              : RefreshIndicator(
                  onRefresh: _loadTips,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tips.length,
                    itemBuilder: (context, index) {
                      return _buildTipCard(_tips[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String? value, String label) {
    final isSelected = _selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? value : null);
          _loadTips();
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTipDetail(tip),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tip.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tip.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipDetail(HealthTip tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 拖动指示器
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 分类标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tip.category,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 标题
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 内容
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExercisesTab() {
    return Column(
      children: [
        // 条件筛选
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _weather,
                  decoration: const InputDecoration(
                    labelText: '天气',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: _weatherOptions
                      .map((opt) => DropdownMenuItem(
                            value: opt['value'],
                            child: Text(opt['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _weather = value);
                      _loadExercises();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _timeSlot,
                  decoration: const InputDecoration(
                    labelText: '时段',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: _timeSlotOptions
                      .map((opt) => DropdownMenuItem(
                            value: opt['value'],
                            child: Text(opt['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _timeSlot = value);
                      _loadExercises();
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // 推荐信息
        if (_exercises != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _exercises!.message,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
              ),
            ),
          ),

        // 运动列表
        Expanded(
          child: _exercises == null || _exercises!.recommendations.isEmpty
              ? const Center(child: Text('暂无推荐'))
              : RefreshIndicator(
                  onRefresh: _loadExercises,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises!.recommendations.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(
                        _exercises!.recommendations[index],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseRecommendation exercise) {
    Color intensityColor;
    switch (exercise.intensity) {
      case 'high':
        intensityColor = AppTheme.errorColor;
        break;
      case 'medium':
        intensityColor = AppTheme.warningColor;
        break;
      default:
        intensityColor = AppTheme.successColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: intensityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.intensityDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: intensityColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              exercise.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildExerciseInfo(
                  Icons.timer,
                  '${exercise.duration} 分钟',
                ),
                const SizedBox(width: 24),
                _buildExerciseInfo(
                  Icons.local_fire_department,
                  '约 ${exercise.caloriesBurned} kcal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
