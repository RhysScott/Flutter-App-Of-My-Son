import 'package:flutter/material.dart';

import 'models.dart';
import 'widgets.dart';

// 病史新增/编辑弹窗
class MedicalRecordDialog extends StatefulWidget {
  final MedicalRecordModel? record;
  final VoidCallback onSave;
  const MedicalRecordDialog({super.key, this.record, required this.onSave});
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
            if (widget.record != null) {
              final updatedRecord = widget.record!.copyWith(
                patientName: _patientNameController.text,
                age: int.parse(_ageController.text),
                gender: _genderController.text,
                chiefComplaint: _chiefComplaintController.text,
                diagnosisResult: _diagnosisController.text,
              );
              Navigator.pop(context, updatedRecord);
            } else {
              final newRecord = MedicalRecordModel(
                recordId: 'M${DateTime.now().millisecondsSinceEpoch}',
                patientName: _patientNameController.text,
                age: int.parse(_ageController.text),
                gender: _genderController.text,
                recordTime: _recordTime,
                chiefComplaint: _chiefComplaintController.text,
                diagnosisResult: _diagnosisController.text,
                checkItems: const [],
              );
              Navigator.pop(context, newRecord);
            }
            widget.onSave();
          },
          child: const Text('保存', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

// 病史详情页
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
      builder: (context) =>
          MedicalRecordDialog(record: widget.record, onSave: () {}),
    );
    if (result != null && mounted) {
      widget.onEdit(result);
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
      widget.onDelete(widget.record.recordId);
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

// 【关键】确保这个类完整公开，无 _ 前缀，可被外部引用
class MedicalRecordListPage extends StatefulWidget {
  const MedicalRecordListPage({super.key}); // 公开构造函数
  @override
  State<MedicalRecordListPage> createState() => _MedicalRecordListPageState();
}

class _MedicalRecordListPageState extends State<MedicalRecordListPage> {
  List<MedicalRecordModel> recordList = [
    const MedicalRecordModel(
      recordId: 'M20260123001',
      patientName: '张三',
      age: 65,
      gender: '男',
      recordTime: '2026-01-23 10:15',
      chiefComplaint: '头晕、心慌1周，伴左侧肢体轻微震颤，日常活动时症状明显，休息后无明显缓解',
      diagnosisResult: '帕金森病（轻度），高血压1级，建议规律服药，定期监测血压及震颤情况',
      checkItems: [
        CheckItemModel(
          itemName: '心率',
          result: '78',
          referenceRange: '60-100',
          unit: '次/分',
        ),
        CheckItemModel(
          itemName: '血压',
          result: '145/90',
          referenceRange: '≤140/90',
          unit: 'mmHg',
        ),
        CheckItemModel(
          itemName: '震颤频率',
          result: '3',
          referenceRange: '0-4',
          unit: 'Hz',
        ),
      ],
    ),
    const MedicalRecordModel(
      recordId: 'M20260120002',
      patientName: '张三',
      age: 65,
      gender: '男',
      recordTime: '2026-01-20 09:30',
      chiefComplaint: '左侧肢体震颤加重3天，睡眠质量差，夜间易醒，醒后难以入睡，每日睡眠不足5小时',
      diagnosisResult: '帕金森病（轻度），失眠，建议调整作息，配合安神类药物改善睡眠',
      checkItems: [
        CheckItemModel(
          itemName: '震颤频率',
          result: '4',
          referenceRange: '0-4',
          unit: 'Hz',
        ),
        CheckItemModel(
          itemName: '睡眠时长',
          result: '5',
          referenceRange: '6-8',
          unit: '小时',
        ),
        CheckItemModel(
          itemName: '心率',
          result: '82',
          referenceRange: '60-100',
          unit: '次/分',
        ),
      ],
    ),
    const MedicalRecordModel(
      recordId: 'M20260115003',
      patientName: '张三',
      age: 65,
      gender: '男',
      recordTime: '2026-01-15 14:20',
      chiefComplaint: '胸闷、气短2天，活动后加重，爬楼梯时需中途休息，无胸痛、呼吸困难症状',
      diagnosisResult: '高血压1级，冠状动脉供血不足，建议减少剧烈活动，规律服用降压及改善循环药物',
      checkItems: [
        CheckItemModel(
          itemName: '血氧饱和度',
          result: '95',
          referenceRange: '≥95',
          unit: '%',
        ),
        CheckItemModel(
          itemName: '脉搏',
          result: '85',
          referenceRange: '60-100',
          unit: '次/分',
        ),
        CheckItemModel(
          itemName: '血压',
          result: '142/88',
          referenceRange: '≤140/90',
          unit: 'mmHg',
        ),
      ],
    ),
  ];

  void _addRecord() async {
    if (!mounted) return;
    final result = await showDialog<MedicalRecordModel>(
      context: context,
      builder: (context) => MedicalRecordDialog(onSave: () => setState(() {})),
    );
    if (result != null && mounted) {
      setState(() => recordList.add(result));
    }
  }

  void _editRecord(MedicalRecordModel updatedRecord) => setState(() {
    final index = recordList.indexWhere(
      (r) => r.recordId == updatedRecord.recordId,
    );
    if (index != -1) {
      recordList[index] = updatedRecord;
    }
  });

  void _deleteRecord(String recordId) => setState(() {
    recordList.removeWhere((r) => r.recordId == recordId);
  });

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
                child: recordList.isEmpty
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        backgroundColor: const Color(0xFF38B2AC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
