// lib/main.dart

import 'dart:async';

import 'package:aaa/auth.dart';
import 'package:aaa/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'nav.dart';
import 'utils/snack.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _requestStoragePermission() async {
  // 1. 指定要申请的权限（存储权限）
  final Permission storagePerm = Permission.storage;

  // 2. 发起申请并获取结果（一行代码完成申请）
  final PermissionStatus status = await storagePerm.request();

  // 3. 简单判断结果并反馈
  String tip;
  if (status == PermissionStatus.granted) {
    tip = "存储权限申请成功！";
  } else {
    tip = "存储权限申请失败！";
  }

  // 4. 弹出提示（无需上下文复杂处理，简化版）
  ScaffoldMessenger.of(
    navigatorKey.currentContext!,
  ).showSnackBar(SnackBar(content: Text(tip)));
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.light,
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp(
          title: '胡承栋小宝宝的App',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: messengerKey, // 只加这一行
          theme: Theme.of(context),
          builder: (context, child) {
            return ShadAppBuilder(child: child!);
          },
          home: const SplashScreen(), // 你的启动页不动
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      var token = await LocalStorage.get("_token");
      _requestStoragePermission();
      if (mounted) {
        if (token.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigationPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/world_alzhelmer.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: const Color(0xFF4299E1),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety, size: 100, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    '胡承栋小朋友的App',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
