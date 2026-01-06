import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class AddRecordScreen extends StatefulWidget {
  final String? initialType;

  const AddRecordScreen({super.key, this.initialType});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedType = 'weight';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _typeOptions = [
    {
      'value': 'weight',
      'label': '体重',
      'icon': Icons.monitor_weight,
      'unit': 'kg',
      'hint': '例如: 70.5',
    },
    {
      'value': 'steps',
      'label': '步数',
      'icon': Icons.directions_walk,
      'unit': '步',
      'hint': '例如: 8500',
    },
    {
      'value': 'blood_pressure_sys',
      'label': '收缩压',
      'icon': Icons.favorite,
      'unit': 'mmHg',
      'hint': '例如: 120',
    },
    {
      'value': 'blood_pressure_dia',
      'label': '舒张压',
      'icon': Icons.favorite_border,
      'unit': 'mmHg',
      'hint': '例如: 80',
    },
    {
      'value': 'heart_rate',
      'label': '心率',
      'icon': Icons.favorite,
      'unit': 'bpm',
      'hint': '例如: 72',
    },
    {
      'value': 'sleep',
      'label': '睡眠',
      'icon': Icons.bedtime,
      'unit': '小时',
      'hint': '例如: 7.5',
    },
    {
      'value': 'water',
      'label': '饮水量',
      'icon': Icons.water_drop,
      'unit': 'ml',
      'hint': '例如: 500',
    },
    {
      'value': 'calories',
      'label': '卡路里',
      'icon': Icons.local_fire_department,
      'unit': 'kcal',
      'hint': '例如: 2000',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentTypeInfo {
    return _typeOptions.firstWhere(
      (t) => t['value'] == _selectedType,
      orElse: () => _typeOptions.first,
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.healthService.createRecord(
        type: _selectedType,
        value: double.parse(_valueController.text),
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        recordDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('记录添加成功'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeInfo = _currentTypeInfo;
    final typeColor = HealthDataType.getColor(_selectedType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加记录'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 类型选择
              const Text(
                '选择类型',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _typeOptions.map((type) {
                  final isSelected = type['value'] == _selectedType;
                  final color = HealthDataType.getColor(type['value']);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = type['value'];
                        _valueController.clear();
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(type['icon'], size: 16, color: isSelected ? color : Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            type['label'],
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? color : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 数值输入
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: typeInfo['label'],
                  hintText: typeInfo['hint'],
                  prefixIcon: Icon(typeInfo['icon'], color: typeColor, size: 20),
                  suffixText: typeInfo['unit'],
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入数值';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return '请输入有效的正数';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 日期选择
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.calendar_today, color: typeColor, size: 20),
                title: const Text('记录日期', style: TextStyle(fontSize: 13)),
                subtitle: Text(
                  DateFormat('yyyy年MM月dd日').format(_selectedDate),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: _selectDate,
              ),
              const SizedBox(height: 10),

              // 备注
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                  hintText: '添加备注信息',
                  prefixIcon: Icon(Icons.note, size: 20),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                maxLines: 2,
                maxLength: 500,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // 提交按钮
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('保存记录', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
