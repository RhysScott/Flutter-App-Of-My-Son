// lib/main.dart

import 'dart:async';
import 'dart:io';

import 'package:aaa/auth.dart';
import 'package:aaa/utils/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'nav.dart';
import 'utils/snack.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> requestMediaPermissionsIfNeeded() async {
  // Web / Desktop：直接返回
  if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return;
  }

  if (!Platform.isAndroid) return;

  // Android 13+
  final photos = await Permission.photos.request();
  final videos = await Permission.videos.request();

  final context = navigatorKey.currentContext;
  if (context == null) return;

  String tip;
  if (photos.isGranted && videos.isGranted) {
    tip = "媒体权限已授权";
  } else {
    tip = "媒体权限未完全授权";
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tip)));
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
      var token = await LocalStorage.get("_user_id");
      requestMediaPermissionsIfNeeded();
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
