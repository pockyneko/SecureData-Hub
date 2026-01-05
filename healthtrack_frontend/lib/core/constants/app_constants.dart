import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  // 主色调 - 健康绿
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);
  
  // 次要色调
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFFFF9800);
  
  // 背景色
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // 状态颜色
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // 健康数据类型颜色
  static const Map<String, Color> healthTypeColors = {
    'weight': Color(0xFF9C27B0),
    'steps': Color(0xFF4CAF50),
    'blood_pressure_sys': Color(0xFFF44336),
    'blood_pressure_dia': Color(0xFFE91E63),
    'heart_rate': Color(0xFFE91E63),
    'sleep': Color(0xFF3F51B5),
    'water': Color(0xFF03A9F4),
    'calories': Color(0xFFFF9800),
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
      ),
    );
  }
}

/// 健康数据类型枚举和工具
class HealthDataType {
  static const String weight = 'weight';
  static const String steps = 'steps';
  static const String bloodPressureSys = 'blood_pressure_sys';
  static const String bloodPressureDia = 'blood_pressure_dia';
  static const String heartRate = 'heart_rate';
  static const String sleep = 'sleep';
  static const String water = 'water';
  static const String calories = 'calories';

  static const Map<String, String> typeNames = {
    weight: '体重',
    steps: '步数',
    bloodPressureSys: '收缩压',
    bloodPressureDia: '舒张压',
    heartRate: '心率',
    sleep: '睡眠',
    water: '饮水量',
    calories: '卡路里',
  };

  static const Map<String, String> typeUnits = {
    weight: 'kg',
    steps: '步',
    bloodPressureSys: 'mmHg',
    bloodPressureDia: 'mmHg',
    heartRate: 'bpm',
    sleep: '小时',
    water: 'ml',
    calories: 'kcal',
  };

  static const Map<String, IconData> typeIcons = {
    weight: Icons.monitor_weight,
    steps: Icons.directions_walk,
    bloodPressureSys: Icons.favorite,
    bloodPressureDia: Icons.favorite_border,
    heartRate: Icons.favorite,
    sleep: Icons.bedtime,
    water: Icons.water_drop,
    calories: Icons.local_fire_department,
  };

  static String getName(String type) => typeNames[type] ?? type;
  static String getUnit(String type) => typeUnits[type] ?? '';
  static IconData getIcon(String type) => typeIcons[type] ?? Icons.health_and_safety;
  static Color getColor(String type) => AppTheme.healthTypeColors[type] ?? AppTheme.primaryColor;
}
