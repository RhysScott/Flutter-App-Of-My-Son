import 'package:flutter/material.dart';

import '../models.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 8), // 移除有问题的 ShadTimePicker，保证显示正常
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        style: const TextStyle(
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
