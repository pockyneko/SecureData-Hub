import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'home/home_screen.dart';
import 'records/records_screen.dart';
import 'analysis/analysis_screen.dart';
import 'tips/tips_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // 用于懒加载的缓存
  final Map<int, Widget> _loadedScreens = {};

  Widget _buildScreen(int index) {
    if (!_loadedScreens.containsKey(index)) {
      switch (index) {
        case 0:
          _loadedScreens[index] = const HomeScreen();
          break;
        case 1:
          _loadedScreens[index] = const RecordsScreen();
          break;
        case 2:
          _loadedScreens[index] = const AnalysisScreen();
          break;
        case 3:
          _loadedScreens[index] = const TipsScreen();
          break;
        case 4:
          _loadedScreens[index] = const ProfileScreen();
          break;
      }
    }
    return _loadedScreens[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(5, (index) {
          // 只构建已访问过的页面和当前页面
          if (index == _currentIndex || _loadedScreens.containsKey(index)) {
            return _buildScreen(index);
          }
          // 未访问的页面用占位符
          return const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list_alt),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            activeIcon: Icon(Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            activeIcon: Icon(Icons.lightbulb),
            label: '百科',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
