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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        indicatorColor: AppTheme.primaryColor.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: '分析',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '发现',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
