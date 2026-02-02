import 'package:aaa/auth.dart';
import 'package:aaa/utils/storage.dart';
import 'package:flutter/material.dart';

// 建议：明确导入每个页面的类名，避免命名冲突
import 'medical_record.dart' show MedicalRecordListPage;
import 'pages/history_data.dart' show DataPage;
import 'pages/home.dart' show HomePage;
import 'pages/profile.dart' show ProfilePage;
import 'pages/sleep_quality.dart' show SleepDataPage; // 重点：确认这里的类名

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;
  late BuildContext context;

  // 页面列表：索引和底部导航item严格对应
  final List<Widget> _pages = const [
    HomePage(), // 0 - 首页
    DataPage(), // 1 - 数据
    SleepDataPage(), // 2 - 睡眠
    MedicalRecordListPage(), // 3 - 病史
    ProfilePage(), // 4 - 我的
  ];

  // 导航栏item配置：和页面列表索引一一对应
  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home, size: 24), label: '首页'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 24), label: '数据'),
    BottomNavigationBarItem(
      icon: Icon(Icons.bedtime_outlined, size: 24),
      label: '睡眠',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.archive, size: 24), label: '病史'),
    BottomNavigationBarItem(icon: Icon(Icons.person, size: 24), label: '我的'),
  ];

  void _onTabTapped(int index) async {
    var token = await LocalStorage.get("_user_id");
    if (!mounted) return;
    if (token.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4299E1),
        unselectedItemColor: const Color(0xFF718096),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: _navItems, // 使用独立的item列表，避免硬编码出错
      ),
    );
  }
}
