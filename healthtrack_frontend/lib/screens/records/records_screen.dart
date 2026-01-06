import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_record_model.dart';
import 'add_record_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<HealthRecord> _records = [];
  bool _isLoading = true;
  String? _selectedType;
  String? _startDate;
  String? _endDate;
  int _offset = 0;
  int _total = 0;
  final int _limit = 50;

  final List<Map<String, String>> _typeOptions = [
    {'value': '', 'label': '全部类型'},
    {'value': 'weight', 'label': '体重'},
    {'value': 'steps', 'label': '步数'},
    {'value': 'blood_pressure_sys', 'label': '收缩压'},
    {'value': 'blood_pressure_dia', 'label': '舒张压'},
    {'value': 'heart_rate', 'label': '心率'},
    {'value': 'sleep', 'label': '睡眠'},
    {'value': 'water', 'label': '饮水量'},
    {'value': 'calories', 'label': '卡路里'},
  ];

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保 widget 树构建完成后再加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
    });
  }

  Future<void> _loadRecords({bool refresh = false}) async {
    if (!mounted) return;
    
    if (refresh) {
      _offset = 0;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final response = await authProvider.healthService.getRecords(
        type: _selectedType?.isNotEmpty == true ? _selectedType : null,
        startDate: _startDate,
        endDate: _endDate,
        limit: _limit,
        offset: _offset,
      );

      if (mounted) {
        setState(() {
          if (refresh || _offset == 0) {
            _records = response.records;
          } else {
            _records.addAll(response.records);
          }
          _total = response.pagination.total;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载记录失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(
              start: DateTime.parse(_startDate!),
              end: DateTime.parse(_endDate!),
            )
          : null,
    );

    if (result != null) {
      setState(() {
        _startDate = DateFormat('yyyy-MM-dd').format(result.start);
        _endDate = DateFormat('yyyy-MM-dd').format(result.end);
      });
      _loadRecords(refresh: true);
    }
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && record.id != null) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.healthService.deleteRecord(record.id!);
        setState(() {
          _records.removeWhere((r) => r.id == record.id);
          _total--;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选状态栏
          _buildFilterStatusBar(),

          // 记录列表
          Expanded(
            child: _isLoading && _records.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _loadRecords(refresh: true),
                        child: _buildRecordsList(),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecordScreen()),
          );
          if (result == true) {
            _loadRecords(refresh: true);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('记录', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // 筛选状态栏
  Widget _buildFilterStatusBar() {
    final hasFilter = _selectedType?.isNotEmpty == true || _startDate != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 当前筛选条件
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: _selectedType?.isNotEmpty == true 
                        ? _typeOptions.firstWhere((t) => t['value'] == _selectedType)['label']!
                        : '全部类型',
                    isActive: _selectedType?.isNotEmpty == true,
                    onTap: () => _showTypeSelector(),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: _startDate != null 
                        ? '${_formatShortDate(_startDate!)}-${_formatShortDate(_endDate!)}'
                        : '选择日期',
                    isActive: _startDate != null,
                    onTap: _selectDateRange,
                  ),
                  if (hasFilter) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _clearAllFilters,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          '清除',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 记录总数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$_total条',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppTheme.primaryColor : Colors.grey[700],
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: isActive ? AppTheme.primaryColor : Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(String date) {
    final d = DateTime.parse(date);
    return '${d.month}/${d.day}';
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _startDate = null;
      _endDate = null;
    });
    _loadRecords(refresh: true);
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('选择类型', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ..._typeOptions.map((opt) => ListTile(
              leading: opt['value']!.isNotEmpty 
                  ? Icon(HealthDataType.getIcon(opt['value']!), 
                      color: HealthDataType.getColor(opt['value']!))
                  : const Icon(Icons.all_inclusive, color: Colors.grey),
              title: Text(opt['label']!),
              trailing: _selectedType == opt['value'] || 
                  (_selectedType == null && opt['value']!.isEmpty)
                  ? Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                setState(() => _selectedType = opt['value']!.isEmpty ? null : opt['value']);
                Navigator.pop(context);
                _loadRecords(refresh: true);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('筛选选项', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('类型筛选'),
              subtitle: Text(_selectedType?.isNotEmpty == true 
                  ? _typeOptions.firstWhere((t) => t['value'] == _selectedType)['label']!
                  : '全部类型'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showTypeSelector();
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('日期范围'),
              subtitle: Text(_startDate != null ? '$_startDate 至 $_endDate' : '不限'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _selectDateRange();
              },
            ),
            if (_selectedType != null || _startDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearAllFilters();
                    },
                    child: const Text('清除所有筛选'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 按日期分组的记录列表
  Widget _buildRecordsList() {
    // 按日期分组
    final Map<String, List<HealthRecord>> groupedRecords = {};
    for (var record in _records) {
      final date = record.recordDate;
      groupedRecords.putIfAbsent(date, () => []);
      groupedRecords[date]!.add(record);
    }

    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 最新的日期在前

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedDates.length + (_records.length < _total ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == sortedDates.length) {
          return _buildLoadMoreButton();
        }
        
        final date = sortedDates[index];
        final records = groupedRecords[date]!;
        
        return _buildDateGroup(date, records);
      },
    );
  }

  Widget _buildDateGroup(String date, List<HealthRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            children: [
              Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${records.length}条',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        // 该日期的记录
        ...records.map((record) => _buildRecordItem(record)),
        const SizedBox(height: 8),
      ],
    );
  }

  String _formatDateHeader(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);
    
    if (recordDate == today) {
      return '今天';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  Widget _buildRecordItem(HealthRecord record) {
    final color = HealthDataType.getColor(record.type);
    final icon = HealthDataType.getIcon(record.type);
    final typeName = HealthDataType.getName(record.type);
    final unit = HealthDataType.getUnit(record.type);

    return Dismissible(
      key: Key('record_${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: AppTheme.errorColor),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这条记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _performDelete(record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showRecordDetail(record),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // 类型图标
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // 类型名称和备注
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (record.note?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            record.note!,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 数值
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatRecordValue(record.value, record.type),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        unit,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatRecordValue(double value, String type) {
    if (type == 'weight' || type == 'sleep') {
      return value.toStringAsFixed(1);
    }
    return value.toInt().toString();
  }

  void _performDelete(HealthRecord record) async {
    if (record.id != null) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.healthService.deleteRecord(record.id!);
        setState(() {
          _records.removeWhere((r) => r.id == record.id);
          _total--;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
          _loadRecords(refresh: true); // 刷新恢复数据
        }
      }
    }
  }

  void _showRecordDetail(HealthRecord record) {
    final color = HealthDataType.getColor(record.type);
    final icon = HealthDataType.getIcon(record.type);
    final typeName = HealthDataType.getName(record.type);
    final unit = HealthDataType.getUnit(record.type);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖动指示器
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // 图标和数值
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(typeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatRecordValue(record.value, record.type),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 16),
            // 详细信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('记录日期', record.recordDate),
                  if (record.note?.isNotEmpty == true)
                    _buildDetailRow('备注', record.note!),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 删除按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteRecord(record);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除记录'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: BorderSide(color: AppTheme.errorColor.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '暂无健康记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加您的第一条记录',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddRecordScreen()),
              );
              if (result == true) {
                _loadRecords(refresh: true);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('添加记录'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton.icon(
                onPressed: () {
                  _offset += _limit;
                  _loadRecords();
                },
                icon: const Icon(Icons.expand_more, size: 18),
                label: const Text('加载更多'),
              ),
      ),
    );
  }
}
