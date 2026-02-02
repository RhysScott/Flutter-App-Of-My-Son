import 'package:aaa/request.dart'; // 导入你的网络请求工具（保持和profile页一致）
import 'package:flutter/material.dart';

import 'models.dart';
import 'widgets.dart';

// 病史新增/编辑弹窗（仅少量修改，移除冗余onSave，保持数据返回逻辑）
class MedicalRecordDialog extends StatefulWidget {
  final MedicalRecordModel? record;
  const MedicalRecordDialog({super.key, this.record}); // 移除冗余onSave参数
  @override
  State<MedicalRecordDialog> createState() => _MedicalRecordDialogState();
}

class _MedicalRecordDialogState extends State<MedicalRecordDialog> {
  late TextEditingController _patientNameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _chiefComplaintController;
  late TextEditingController _diagnosisController;
  late String _recordTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _recordTime =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    if (widget.record != null) {
      _patientNameController = TextEditingController(
        text: widget.record!.patientName,
      );
      _ageController = TextEditingController(
        text: widget.record!.age.toString(),
      );
      _genderController = TextEditingController(text: widget.record!.gender);
      _chiefComplaintController = TextEditingController(
        text: widget.record!.chiefComplaint,
      );
      _diagnosisController = TextEditingController(
        text: widget.record!.diagnosisResult,
      );
      _recordTime = widget.record!.recordTime;
    } else {
      _patientNameController = TextEditingController(text: '张三');
      _ageController = TextEditingController(text: '65');
      _genderController = TextEditingController(text: '男');
      _chiefComplaintController = TextEditingController();
      _diagnosisController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _chiefComplaintController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  // 数据校验辅助方法
  bool _validateForm() {
    if (_patientNameController.text.trim().isEmpty) return false;
    if (_ageController.text.trim().isEmpty) return false;
    try {
      int.parse(_ageController.text);
    } catch (e) {
      return false;
    }
    if (_genderController.text.trim().isEmpty) return false;
    if (_chiefComplaintController.text.trim().isEmpty) return false;
    if (_diagnosisController.text.trim().isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑病史', style: TextStyle(fontSize: 16)),
      contentPadding: const EdgeInsets.all(12),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _patientNameController,
              decoration: const InputDecoration(labelText: '患者姓名'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: '年龄'),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _genderController,
              decoration: const InputDecoration(labelText: '性别'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _chiefComplaintController,
              decoration: const InputDecoration(labelText: '主诉'),
              maxLines: 2,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(labelText: '诊断结果'),
              maxLines: 2,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(fontSize: 14)),
        ),
        TextButton(
          onPressed: () {
            // 先校验表单
            if (!_validateForm()) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('请填写完整且有效的信息')));
              return;
            }

            if (widget.record != null) {
              // 编辑已有记录
              final updatedRecord = widget.record!.copyWith(
                patientName: _patientNameController.text.trim(),
                age: int.parse(_ageController.text.trim()),
                gender: _genderController.text.trim(),
                chiefComplaint: _chiefComplaintController.text.trim(),
                diagnosisResult: _diagnosisController.text.trim(),
              );
              Navigator.pop(context, updatedRecord);
            } else {
              // 新增记录
              final newRecord = MedicalRecordModel(
                recordId: 'M${DateTime.now().millisecondsSinceEpoch}',
                patientName: _patientNameController.text.trim(),
                age: int.parse(_ageController.text.trim()),
                gender: _genderController.text.trim(),
                recordTime: _recordTime,
                chiefComplaint: _chiefComplaintController.text.trim(),
                diagnosisResult: _diagnosisController.text.trim(),
                checkItems: const [],
              );
              Navigator.pop(context, newRecord);
            }
          },
          child: const Text('保存', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

// 病史详情页（无核心修改，仅保留交互，网络请求由列表页处理）
class MedicalRecordDetailPage extends StatefulWidget {
  final MedicalRecordModel record;
  final Function(MedicalRecordModel) onEdit;
  final Function(String) onDelete;
  const MedicalRecordDetailPage({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  State<MedicalRecordDetailPage> createState() =>
      _MedicalRecordDetailPageState();
}

class _MedicalRecordDetailPageState extends State<MedicalRecordDetailPage> {
  void _handleEdit() async {
    if (!mounted) return;
    final result = await showDialog<MedicalRecordModel>(
      context: context,
      builder: (context) => MedicalRecordDialog(record: widget.record),
    );
    if (result != null && mounted) {
      widget.onEdit(result); // 回调列表页处理网络请求
      Navigator.pop(context);
    }
  }

  void _handleDelete() async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这条病史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      widget.onDelete(widget.record.recordId); // 回调列表页处理网络请求
      Navigator.pop(context);
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label：',
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF2D3748),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF4299E1),
                            size: 20,
                          ),
                          onPressed: _handleEdit,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: _handleDelete,
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '病史详情',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '基础信息',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      _buildInfoItem('病史编号', widget.record.recordId),
                      _buildInfoItem('患者姓名', widget.record.patientName),
                      _buildInfoItem('年龄', '${widget.record.age}岁'),
                      _buildInfoItem('性别', widget.record.gender),
                      _buildInfoItem('就诊时间', widget.record.recordTime),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '诊断信息',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '主诉',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4299E1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.record.chiefComplaint,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8FB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF38A169),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '诊断结果',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF38A169),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.record.diagnosisResult,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2D3748),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '检查项目',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      Column(
                        children: widget.record.checkItems
                            .map(
                              (item) => Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: const TextStyle(
                                        color: Color(0xFF2D3748),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${item.result}${item.unit}',
                                      style: const TextStyle(
                                        color: Color(0xFF718096),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '参考值：${item.referenceRange}',
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          205,
                                          197,
                                          197,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
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

// 病史列表页（核心修复：解决 JsonMap 转 List 错误，其他逻辑不变）
class MedicalRecordListPage extends StatefulWidget {
  const MedicalRecordListPage({super.key});
  @override
  State<MedicalRecordListPage> createState() => _MedicalRecordListPageState();
}

class _MedicalRecordListPageState extends State<MedicalRecordListPage> {
  List<MedicalRecordModel> recordList = [];
  bool _isLoading = true; // 加载状态
  bool _isOperating = false; // 操作（增删改）状态，避免重复提交

  @override
  void initState() {
    super.initState();
    // 初始化加载服务器病史数据
    _loadMedicalRecordsFromServer();
  }

  /// 1. 从服务器加载病史列表（修复核心错误）
  Future<void> _loadMedicalRecordsFromServer() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 关键修改1：补充 /api 前缀，对接后端正确接口
      final res = await HttpUtil().get("/user/medical/records");
      debugPrint("病史接口返回完整数据：$res");

      // 关键修改2：兼容 data 是 Map 或 List 的情况，避免类型转换错误
      dynamic responseData = res?["data"];
      List<dynamic> rawData = [];

      // 判断返回数据类型，适配后端格式
      if (responseData is List) {
        rawData = responseData;
      } else if (responseData is Map) {
        // 若后端返回 data: {list: [...]}，则取 list 数组
        rawData = responseData["list"] ?? [];
      }

      // 转换为 MedicalRecordModel 列表
      List<MedicalRecordModel> serverRecords = rawData
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => MedicalRecordModel.fromJson(item),
          ) // 依赖 models.dart 中的 fromJson 方法
          .toList();

      setState(() {
        recordList = serverRecords;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("加载病史列表失败：$e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("加载病史失败，请稍后重试")));
      }
    }
  }

  /// 2. 新增病史（提交到服务器，补充 /api 前缀）
  Future<void> _addRecord() async {
    if (_isOperating || !mounted) return;

    // 弹出新增弹窗
    final result = await showDialog<MedicalRecordModel>(
      context: context,
      builder: (context) => const MedicalRecordDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _isOperating = true;
      });

      try {
        // 关键修改：补充 /api 前缀
        final res = await HttpUtil().post(
          "/user/medical/record/add",
          data: result.toJson(), // 依赖 MedicalRecordModel 的 toJson 方法
        );

        if (res?["code"] == 200) {
          // 新增成功，刷新列表
          setState(() {
            recordList.add(result);
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("病史新增成功")));
        } else {
          throw Exception(res?["msg"] ?? "新增失败");
        }
      } catch (e) {
        debugPrint("新增病史失败：$e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("新增失败：${e.toString()}")));
      } finally {
        if (mounted) {
          setState(() {
            _isOperating = false;
          });
        }
      }
    }
  }

  /// 3. 编辑病史（提交到服务器，补充 /api 前缀）
  Future<void> _editRecord(MedicalRecordModel updatedRecord) async {
    if (_isOperating || !mounted) return;

    setState(() {
      _isOperating = true;
    });

    try {
      // 关键修改：补充 /api 前缀
      final res = await HttpUtil().post(
        "/user/medical/record/edit",
        data: updatedRecord.toJson(),
      );

      if (res?["code"] == 200) {
        // 编辑成功，更新本地列表
        setState(() {
          final index = recordList.indexWhere(
            (r) => r.recordId == updatedRecord.recordId,
          );
          if (index != -1) {
            recordList[index] = updatedRecord;
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("病史编辑成功")));
      } else {
        throw Exception(res?["msg"] ?? "编辑失败");
      }
    } catch (e) {
      debugPrint("编辑病史失败：$e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("编辑失败：${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() {
          _isOperating = false;
        });
      }
    }
  }

  /// 4. 删除病史（提交到服务器，补充 /api 前缀）
  Future<void> _deleteRecord(String recordId) async {
    if (_isOperating || !mounted) return;

    setState(() {
      _isOperating = true;
    });

    try {
      // 关键修改：补充 /api 前缀
      final res = await HttpUtil().post(
        "/user/medical/record/delete",
        data: {"recordId": recordId},
      );

      if (res?["code"] == 200) {
        // 删除成功，更新本地列表
        setState(() {
          recordList.removeWhere((r) => r.recordId == recordId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("病史删除成功")));
      } else {
        throw Exception(res?["msg"] ?? "删除失败");
      }
    } catch (e) {
      debugPrint("删除病史失败：$e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("删除失败：${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() {
          _isOperating = false;
        });
      }
    }
  }

  /// 跳转到详情页
  void _toDetailPage(MedicalRecordModel record) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MedicalRecordDetailPage(
        record: record,
        onEdit: _editRecord,
        onDelete: _deleteRecord,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '病史列表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator()) // 加载中动画
                    : recordList.isEmpty
                    ? const Center(
                        child: Text('暂无病史记录', style: TextStyle(fontSize: 14)),
                      )
                    : ListView.builder(
                        itemCount: recordList.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) => MedicalRecordCard(
                          record: recordList[index],
                          onTap: () => _toDetailPage(recordList[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          !_isOperating // 操作中隐藏新增按钮，避免重复提交
          ? FloatingActionButton(
              onPressed: _addRecord,
              backgroundColor: const Color(0xFF38B2AC),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
