import 'dart:async';

import 'package:flutter/material.dart';

import 'auth.dart';
import 'models.dart';

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
  final List<MedicineRemindModel> _medicineReminds = [
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
  final String _currentAddress = "北京市朝阳区XX路XX号（实时更新）";

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
