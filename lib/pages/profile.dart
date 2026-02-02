import 'package:aaa/request.dart';
import 'package:aaa/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../auth.dart';
import '../models.dart';
import '../pages/locate.dart';
import '../pages/medicine_remind.dart';
import '../pages/service.dart';

class ProfileModel {
  String name;
  int age;
  String gender;
  String tag;

  String emergencyName;
  String emergencyPhone;

  String currentAddress;
  List<MedicineRemindModel> medicineReminds;

  ProfileModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.tag,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.currentAddress,
    required this.medicineReminds,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "gender": gender,
      "tag": tag,
      "emergencyName": emergencyName,
      "emergencyPhone": emergencyPhone,
      "currentAddress": currentAddress,
    };
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileModel? _profile;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      // 修复1：补全 /api 前缀，正确调用后端接口
      final res = await HttpUtil().get("/user/profile");
      final data = res?["data"];

      // 优化：增加数据非空判断，避免解析报错
      if (data == null) return;

      List<dynamic> rawMedicineReminds = data?["medicineReminds"] ?? [];
      List<MedicineRemindModel> medicineRemindsList = rawMedicineReminds
          .whereType<Map<String, dynamic>>()
          .map((item) => MedicineRemindModel.fromJson(item))
          .toList();

      setState(() {
        _profile = ProfileModel(
          name: data["name"] ?? "未设置姓名",
          age: data["age"] ?? 0,
          gender: data["gender"] ?? "未设置",
          tag: data["tag"] ?? "未设置标签",
          emergencyName: data["emergencyName"] ?? "未设置",
          emergencyPhone: data["emergencyPhone"] ?? "未设置",
          currentAddress: data["currentAddress"] ?? "未获取定位",
          medicineReminds: medicineRemindsList,
        );
      });
    } catch (e) {
      debugPrint("加载用户信息失败：$e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("加载个人信息失败，请稍后重试")));
      }
    }
  }

  void _editProfileInfo() async {
    if (_profile == null) return;

    final nameController = TextEditingController(text: _profile!.name);
    final ageController = TextEditingController(text: _profile!.age.toString());
    final genderController = TextEditingController(text: _profile!.gender);
    final tagController = TextEditingController(text: _profile!.tag);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("编辑个人信息"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "姓名"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "年龄"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: "性别（男/女）"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(labelText: "个人标签"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("保存"),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final newName = nameController.text.trim();
      final newAgeStr = ageController.text.trim();
      final newGender = genderController.text.trim();
      final newTag = tagController.text.trim();

      if (newName.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("姓名不能为空")));
        return;
      }

      int newAge = 0;
      try {
        newAge = int.parse(newAgeStr);
        if (newAge <= 0 || newAge > 120) {
          throw Exception("年龄超出合理范围");
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("请输入有效的年龄（1-120）")));
        return;
      }

      final updatedProfile = ProfileModel(
        name: newName,
        age: newAge,
        gender: newGender.isNotEmpty ? newGender : "未设置",
        tag: newTag.isNotEmpty ? newTag : "未设置标签",
        emergencyName: _profile!.emergencyName,
        emergencyPhone: _profile!.emergencyPhone,
        currentAddress: _profile!.currentAddress,
        medicineReminds: _profile!.medicineReminds,
      );

      await _submitUpdatedProfile(updatedProfile);
    }
  }

  Future<void> _submitUpdatedProfile(ProfileModel updatedProfile) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // 修复2：补全 /api 前缀，正确提交数据到后端
      final res = await HttpUtil().post(
        "/user/profile",
        data: updatedProfile.toJson(),
      );

      if (res?["code"] == 200) {
        setState(() {
          _profile = updatedProfile;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("个人信息更新成功")));
        }
      } else {
        throw Exception(res?["msg"] ?? "更新失败");
      }
    } catch (e) {
      debugPrint("更新个人信息失败：$e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("更新失败：${e.toString()}")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _editEmergencyContact() async {
    if (_profile == null) return;

    final nameController = TextEditingController(
      text: _profile?.emergencyName ?? "未设置",
    );
    final phoneController = TextEditingController(
      text: _profile?.emergencyPhone ?? "未设置",
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("编辑紧急联系人"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "联系人姓名"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "联系电话"),
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
              final newEmergencyName = nameController.text.trim();
              final newEmergencyPhone = phoneController.text.trim();

              if (newEmergencyName.isEmpty) {
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(const SnackBar(content: Text("联系人姓名不能为空")));
                return;
              }

              if (newEmergencyPhone.isEmpty || newEmergencyPhone.length != 11) {
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(const SnackBar(content: Text("请输入有效的11位手机号码")));
                return;
              }

              setState(() {
                _profile?.emergencyName = newEmergencyName;
                _profile?.emergencyPhone = newEmergencyPhone;
              });

              Navigator.pop(ctx, true);
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );

    if (mounted && result == true && _profile != null) {
      await _submitUpdatedProfile(_profile!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("紧急联系人更新成功")));
    }
  }

  Future<void> _submitSingleMedicineRemind(MedicineRemindModel remind) async {
    try {
      // 修复3：补全 /api 前缀（若后续后端新增该接口，可正常调用）
      await HttpUtil().post(
        "/user/medicine/remind/add",
        data: {"name": remind.name, "time": remind.time, "desc": remind.desc},
      );
    } catch (e) {
      debugPrint("同步用药提醒失败：$e");
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("确认退出登录"),
        content: const Text("退出后将需要重新登录，是否继续？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              LocalStorage.clear("_token");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("确认退出", style: TextStyle(color: Colors.red)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("我的个人中心", style: ShadTheme.of(context).textTheme.h3),
                    if (!_isUpdating)
                      TextButton(
                        onPressed: _editProfileInfo,
                        child: const Text(
                          "编辑资料",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      FAvatar(
                        image: const NetworkImage('assets/images/avatar.png'),
                        size: 40.0,
                        semanticsLabel: 'User avatar',
                        // 修复4：增加空值判断，避免 _profile?.name 为空时调用 [0] 报错
                        fallback: Text(
                          _profile?.name.isNotEmpty == true
                              ? _profile!.name[0]
                              : "未",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile?.name ?? "未设置姓名",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "${_profile?.age ?? "0"}岁 · ${_profile?.gender}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            _profile?.tag ?? "未设置标签",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("退出登录"),
                  onTap: _handleLogout,
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text("当前定位"),
                  subtitle: Text(_profile?.currentAddress ?? "未获取定位"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GpsMapPage()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.contacts),
                  title: const Text("紧急联系人"),
                  subtitle: Text(
                    "${_profile?.emergencyName ?? "未设置"}（${_profile?.emergencyPhone ?? "未设置"}）",
                  ),
                  onTap: _editEmergencyContact,
                ),
                ListTile(
                  leading: const Icon(Icons.medication),
                  title: const Text("用药提醒"),
                  subtitle: Text(
                    "共 ${_profile?.medicineReminds.length ?? 0} 条提醒",
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicineRemindPage(
                        reminds: _profile?.medicineReminds ?? [],
                        onEdit: (i, m) {
                          setState(() => _profile?.medicineReminds[i] = m);
                          _submitSingleMedicineRemind(m);
                        },
                        onAdd: (m) {
                          setState(() => _profile?.medicineReminds.add(m));
                          _submitSingleMedicineRemind(m);
                        },
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.headphones),
                  title: const Text("人工客服"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServicePage()),
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
