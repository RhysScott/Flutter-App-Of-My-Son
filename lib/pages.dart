import 'dart:math';

import 'package:flutter/material.dart';

import 'auth.dart';
import 'models.dart';
import 'widgets.dart';

// 首页 - 无AppBar、无基础病史
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _heartRate = 0;
  int _pulse = 76;
  int _sleepHours = 8;
  int _tremorFrequency = 3;
  String _sleepQuality = "良";
  final BasicHistoryModel _basicInfo = const BasicHistoryModel(
    bloodType: "A型",
    basicHistories: ["帕金森病（轻度）", "高血压1级", "轻度失眠"],
  );
  final int _emergencyThreshold = 60;

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

  void _updateTremor() async {
    final textController = TextEditingController(
      text: _tremorFrequency.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("更新震颤频率"),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "输入震颤频率（Hz）"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(textController.text) ?? _tremorFrequency;
              Navigator.pop(ctx, val);
            },
            child: const Text("确认"),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _tremorFrequency = result);
  }

  void _switchSleepQuality() => setState(() {
    _sleepQuality = _sleepQuality == "优"
        ? "良"
        : _sleepQuality == "良"
        ? "差"
        : "优";
  });

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

  List<RecipeCard> _getRecipes() {
    return [
      RecipeCard(
        title: "帕金森+高血压 今日推荐食谱",
        foods: ["芹菜炒百合（降压）", "鸡蛋羹（易咀嚼）", "冬瓜海带汤（低盐）", "杂粮饭（控糖）", "清蒸鲈鱼（补蛋白）"],
      ),
      RecipeCard(
        title: "失眠友好辅助食谱",
        foods: ["小米粥（助眠）", "百合莲子汤（安神）", "温牛奶（睡前喝）", "香蕉（补镁）"],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 24 - 10) / 2;
    final posterHeight = screenWidth * 0.6;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
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
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        size: 60,
                        color: Color(0xFF4299E1),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "健康监测中心",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: StatisticCard(
                        title: "病史总数",
                        value: "3",
                        icon: Icons.file_copy,
                        color: const Color(0xFF4299E1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: StatisticCard(
                        title: "今日监测",
                        value: "6项",
                        icon: Icons.timeline,
                        color: const Color(0xFF38A169),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: StatisticCard(
                        title: "健康状态",
                        value: "良好",
                        icon: Icons.check_circle,
                        color: const Color(0xFFED8936),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "智能食谱推荐（适配病史）",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(children: _getRecipes()),

              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "核心监测指标",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
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
                    onTap: _updateTremor,
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
                        onTap: _switchSleepQuality,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 2),
                        child: Text(
                          "睡眠质量：$_sleepQuality",
                          style: TextStyle(
                            fontSize: 12,
                            color: _sleepQuality == "优"
                                ? const Color(0xFF38A169)
                                : _sleepQuality == "良"
                                ? const Color(0xFFED8936)
                                : const Color(0xFFE53E3E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),
              EmergencyTipCard(
                title: "紧急预警设置",
                content: "心率/脉搏低于$_emergencyThreshold 将触发紧急联系（120+家属）",
                color: const Color(0xFFE53E3E),
              ),
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

// 数据页 - 无AppBar
class DataPage extends StatefulWidget {
  const DataPage({super.key});
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final List<WeekDataModel> _twoWeekData = List.generate(14, (index) {
    final date = DateTime.now().subtract(Duration(days: 13 - index));
    return WeekDataModel(
      date:
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      tremorFrequency: Random().nextInt(5) + 1,
      sleepHours: Random().nextInt(5) + 6,
      sleepQuality: Random().nextInt(3) == 0
          ? "优"
          : Random().nextInt(3) == 1
          ? "良"
          : "差",
      heartRate: Random().nextInt(30) + 65,
      pulse: Random().nextInt(30) + 65,
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatisticCard(
                        title: "本周平均心率",
                        value: "75 BPM",
                        icon: Icons.favorite,
                        color: const Color(0xFFE53E3E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticCard(
                        title: "本周平均睡眠",
                        value: "7.5 小时",
                        icon: Icons.bedtime,
                        color: const Color(0xFF4299E1),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "近14天完整数据（自动存储）",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _twoWeekData.length,
                    itemBuilder: (ctx, index) {
                      final data = _twoWeekData[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              data.date,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "震颤频率：${data.tremorFrequency} Hz | 睡眠：${data.sleepHours} 小时（${data.sleepQuality}）",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF718096),
                                    ),
                                  ),
                                  Text(
                                    "心率：${data.heartRate} BPM | 脉搏：${data.pulse} 次/分",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF718096),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index != _twoWeekData.length - 1)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 我的页面 - 新增退出登录、GPS跳转地图
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 紧急联系人可编辑
  String _emergencyName = "妈妈";
  String _emergencyPhone = "138****1234";
  // 用药提醒可编辑
  List<MedicineRemindModel> _medicineReminds = [
    const MedicineRemindModel(
      name: "美多巴（帕金森）",
      time: "08:00",
      desc: "饭前30分钟，1片/次",
    ),
    const MedicineRemindModel(
      name: "硝苯地平（高血压）",
      time: "18:00",
      desc: "饭后，1片/次",
    ),
    const MedicineRemindModel(name: "助眠片", time: "21:30", desc: "睡前服用，半片/次"),
  ];
  String _currentAddress = "北京市朝阳区XX路XX号（实时更新）";

  // 编辑紧急联系人
  void _editEmergencyContact() async {
    final nameController = TextEditingController(text: _emergencyName);
    final phoneController = TextEditingController(text: _emergencyPhone);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("编辑紧急联系人"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "姓名",
                hintText: "输入家属姓名",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "电话",
                hintText: "输入联系电话",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                setState(() {
                  _emergencyName = nameController.text;
                  _emergencyPhone = phoneController.text;
                });
                Navigator.pop(ctx, true);
              }
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("紧急联系人已更新")));
    }
  }

  // 退出登录
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("确认退出"),
        content: const Text("确定要退出登录吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text("退出登录", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 个人信息
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4F8),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 35,
                          color: Color(0xFF4299E1),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "小朋友",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "65岁 · 男",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "帕金森病随访患者",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4299E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 退出登录（新增）
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEEBC8).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Color(0xFFED8936),
                      size: 20,
                    ),
                  ),
                  title: const Text("退出登录"),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF718096),
                  ),
                  onTap: _handleLogout,
                ),

                // GPS定位 跳转地图
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4F8).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF4299E1),
                      size: 20,
                    ),
                  ),
                  title: const Text("当前定位"),
                  subtitle: Text(
                    _currentAddress,
                    style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const GpsMapPage()),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF718096),
                  ),
                ),

                // 紧急联系人 可编辑
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEEBC8).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.contacts,
                      color: Color(0xFFED8936),
                      size: 20,
                    ),
                  ),
                  title: const Text("紧急联系人"),
                  subtitle: Text(
                    "$_emergencyName（$_emergencyPhone）- 优先联系",
                    style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF718096),
                  ),
                  onTap: _editEmergencyContact,
                ),

                // 用药提醒 可编辑（带返回）
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC6F6D5).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: Color(0xFF38A169),
                      size: 20,
                    ),
                  ),
                  title: const Text("用药提醒"),
                  subtitle: Text(
                    "共 ${_medicineReminds.length} 条，按时提醒服药",
                    style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF718096),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => MedicineRemindPage(
                        reminds: _medicineReminds,
                        onEdit: (index, newRemind) =>
                            setState(() => _medicineReminds[index] = newRemind),
                        onAdd: (newRemind) =>
                            setState(() => _medicineReminds.add(newRemind)),
                      ),
                    ),
                  ),
                ),

                // 人工客服 聊天式（带返回）
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEE3F8).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.headphones,
                      color: Color(0xFF3182CE),
                      size: 20,
                    ),
                  ),
                  title: const Text("人工客服"),
                  subtitle: const Text(
                    "工作日 9:00-18:00 在线，优先解决用药/监测问题",
                    style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF718096),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const MockServicePage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// GPS地图页面
class GpsMapPage extends StatelessWidget {
  const GpsMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFE8F4F8),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Color(0xFF4299E1)),
                  SizedBox(height: 20),
                  Text(
                    "实时GPS定位地图",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "当前位置：北京市朝阳区XX路XX号",
                    style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "定位精度：5米 | 卫星信号：强",
                    style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 用药提醒详情页（带返回按钮，新增）
class MedicineRemindPage extends StatelessWidget {
  final List<MedicineRemindModel> reminds;
  final Function(int, MedicineRemindModel) onEdit;
  final Function(MedicineRemindModel) onAdd;
  const MedicineRemindPage({
    super.key,
    required this.reminds,
    required this.onEdit,
    required this.onAdd,
  });

  void _editRemind(
    BuildContext context,
    int index,
    MedicineRemindModel remind,
  ) async {
    final nameController = TextEditingController(text: remind.name);
    final timeController = TextEditingController(text: remind.time);
    final descController = TextEditingController(text: remind.desc);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("编辑用药提醒"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "药品名称"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: "服药时间（如：08:00）"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "备注说明"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  timeController.text.isNotEmpty) {
                onEdit(
                  index,
                  MedicineRemindModel(
                    name: nameController.text,
                    time: timeController.text,
                    desc: descController.text,
                  ),
                );
                Navigator.pop(ctx, true);
              }
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("用药提醒已更新")));
    }
  }

  void _addRemind(BuildContext context) async {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    final descController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("新增用药提醒"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "药品名称"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: "服药时间（如：08:00）"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "备注说明"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  timeController.text.isNotEmpty) {
                onAdd(
                  MedicineRemindModel(
                    name: nameController.text,
                    time: timeController.text,
                    desc: descController.text,
                  ),
                );
                Navigator.pop(ctx, true);
              }
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("新增用药提醒成功")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部返回栏（新增，返回上级）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2D3748),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '用药提醒列表',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // 用药提醒列表
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  itemCount: reminds.length,
                  itemBuilder: (_, index) {
                    final remind = reminds[index];
                    return ListTile(
                      title: Text(remind.name),
                      subtitle: Text(
                        "时间：${remind.time} | 备注：${remind.desc}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF4299E1)),
                        onPressed: () => _editRemind(context, index, remind),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRemind(context),
        backgroundColor: const Color(0xFF4299E1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 人工客服（聊天式，带返回，新增）
class MockServicePage extends StatefulWidget {
  const MockServicePage({super.key});

  @override
  State<MockServicePage> createState() => _MockServicePageState();
}

class _MockServicePageState extends State<MockServicePage> {
  final List<Map<String, dynamic>> _messages = [
    {'text': '您好！我是您的专属健康客服，工作日9:00-18:00在线~', 'isUser': false},
  ];
  final _textController = TextEditingController();

  // 发送消息
  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _textController.text, 'isUser': true});
        _textController.clear();
      });
      // 模拟客服延迟回复
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({'text': '感谢您的咨询，您的问题我们已记录，会尽快为您处理！', 'isUser': false});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部返回栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2D3748),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '人工客服',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // 聊天列表（核心：聊天式布局）
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (_, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg['isUser']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: msg['isUser']
                            ? const Color(0xFF4299E1)
                            : const Color(0xFFE8F4F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: msg['isUser']
                              ? Colors.white
                              : const Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 输入框（发送消息）
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '输入您的问题...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F8FB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF4299E1),
                      size: 24,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
