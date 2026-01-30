import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';
import '../request.dart';
import '../widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _heartRate = -1;
  int _pulse = -1;
  int _sleepHours = -1;
  int _tremorFrequency = -1;
  final int _emergencyThreshold = 60;
  Timer? _dashboardRefreshTimer;
  List<RecipeCard> _recipes = [];

  @override
  void initState() {
    super.initState();
    _getDashboardData();
    _getRecipes();

    //* 定时刷新
    _dashboardRefreshTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) {
      _getDashboardData();
      _getRecipes();
    });
  }

  @override
  void dispose() {
    _dashboardRefreshTimer?.cancel();
    super.dispose();
  }

  void _getDashboardData() async {
    try {
      Map<String, dynamic>? res = await HttpUtil().get("/dashboard");
      _heartRate = res?["data"]?["heart_rate"];
      _pulse = res?["data"]?["pulse"];
      _sleepHours = res?["data"]?["sleep_hours"];
      _tremorFrequency = res?["data"]?["tremor_frequency"];
      setState(() {});
    } catch (e) {
      print("发生错误: $e");
    }
  }

  (String, Color) _getTremorStatus(int value) {
    if (value <= 2) return ("轻度", const Color(0xFF38A169));
    if (value <= 4) return ("中度", const Color(0xFFED8936));
    return ("重度", const Color(0xFFE53E3E));
  }

  (String, Color) _getSleepStatus(int value) {
    if (value == 0) return ("未睡眠", const Color(0xFF718096));
    if (value < 4) return ("严重不足", const Color(0xFFE53E3E));
    if (value < 7) return ("睡眠不足", const Color(0xFFED8936));
    if (value <= 10) return ("睡眠充足", const Color(0xFF38A169));
    return ("睡眠过长", const Color(0xFF9F7AEA));
  }

  (String, Color) _getHeartRateStatus(int value) => value < 60
      ? ("心动过缓", const Color(0xFFE53E3E))
      : value <= 100
      ? ("心率正常", const Color(0xFF38A169))
      : value <= 120
      ? ("心动过速", const Color(0xFFED8936))
      : ("心率过快", const Color(0xFFE53E3E));

  (String, Color) _getPulseStatus(int value) => value < 60
      ? ("脉搏过缓", const Color(0xFFE53E3E))
      : value <= 100
      ? ("脉搏正常", const Color(0xFF38A169))
      : value <= 120
      ? ("脉搏过速", const Color(0xFFED8936))
      : ("脉搏过快", const Color(0xFFE53E3E));

  void _checkEmergency() {
    if (_heartRate < _emergencyThreshold || _pulse < _emergencyThreshold) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("紧急警告！", style: TextStyle(color: Colors.red)),
          content: const Text("心率/脉搏低于安全阈值，是否拨打120或联系家属？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("正在拨打120...")));
                Navigator.pop(ctx);
              },
              child: const Text("拨打120", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("正在联系紧急联系人...")));
                Navigator.pop(ctx);
              },
              child: const Text("联系家属"),
            ),
          ],
        ),
      );
    }
  }

  void _getRecipes() async {
    List<RecipeCard> cards = [
      RecipeCard(
        title: "早餐",
        foods: ["芹菜炒百合（降压）", "鸡蛋羹（易咀嚼）", "冬瓜海带汤（低盐）", "杂粮饭（控糖）", "清蒸鲈鱼（补蛋白）"],
      ),
      RecipeCard(
        title: "午餐",
        foods: ["小米粥（助眠）", "百合莲子汤（安神）", "温牛奶（睡前喝）", "香蕉（补镁）"],
      ),
      RecipeCard(
        title: "晚餐",
        foods: ["清炒西兰花（低脂）", "豆腐炖排骨（补钙）", "凉拌黄瓜（低盐）", "糙米饭（控糖）"],
      ),
    ];

    try {
      Map<String, dynamic>? res = await HttpUtil().get("/recipes");

      if (res != null && res["code"] == 200) {
        List<dynamic> recipeDataList = res["data"] ?? [];
        cards.clear();

        for (var item in recipeDataList) {
          String cardTitle = item["title"] ?? "未知餐食";
          List<String> cardFoods = List<String>.from(item["foods"] ?? []);

          cards.add(RecipeCard(title: cardTitle, foods: cardFoods));
        }
      }
    } catch (e) {
      print("发生错误: $e");
    }

    _recipes = cards;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 24 - 10) / 2;
    final posterHeight = screenWidth * 1.2;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "健康",
                  style: TextStyle(
                    fontSize: GlobalConfig.titleSize,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              //* 首页海报
              Container(
                width: double.infinity,
                height: posterHeight,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFE8F4F8), Color(0xFFF0F8FB)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/images/poster.png",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text("海报加载失败");
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HealthIndicatorCard(
                    value: _heartRate,
                    title: "心率",
                    icon: Icons.favorite,
                    unit: "BPM",
                    getStatus: _getHeartRateStatus,
                    width: cardWidth,
                  ),
                  HealthIndicatorCard(
                    value: _pulse,
                    title: "脉搏",
                    icon: Icons.favorite_border,
                    unit: "次/分",
                    getStatus: _getPulseStatus,
                    width: cardWidth,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HealthIndicatorCard(
                    value: _tremorFrequency,
                    title: "震颤频率",
                    icon: Icons.tune,
                    unit: "Hz",
                    getStatus: _getTremorStatus,
                    width: cardWidth,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HealthIndicatorCard(
                        value: _sleepHours,
                        title: "睡眠时长",
                        icon: Icons.bedtime,
                        unit: "小时",
                        getStatus: _getSleepStatus,
                        width: cardWidth,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),
              EmergencyTipCard(
                title: "紧急预警设置",
                content: "心率/脉搏低于$_emergencyThreshold 将触发紧急联络120急救和紧急联系人",
                color: const Color(0xFFE53E3E),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "智能食谱推荐",
                  style: TextStyle(
                    fontSize: GlobalConfig.subTitleSize,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(children: _recipes as List<Widget>),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkEmergency,
        backgroundColor: const Color(0xFFE53E3E),
        child: const Icon(Icons.warning),
      ),
    );
  }
}
