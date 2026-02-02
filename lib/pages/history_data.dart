import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../request.dart';
import '../widgets.dart';

class StatusRecord {
  final String id;
  final num heartRate;
  final num tremorFrequency;
  final DateTime datetime;
  final num sleepDuration;
  final num pulse;
  final String sleepQuality;

  StatusRecord({
    required this.id,
    required this.heartRate,
    required this.tremorFrequency,
    required String datetime,
    required this.sleepDuration,
    required this.pulse,
    required this.sleepQuality,
  }) : datetime = DateTime.parse(datetime);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "heart_rate": heartRate,
      "tremor_frequency": tremorFrequency,
      "datetime": datetime.toIso8601String(),
      "sleep_duration": sleepDuration,
      "pulse": pulse,
      "sleep_quality": sleepQuality,
    };
  }

  factory StatusRecord.fromJson(Map<String, dynamic> json) {
    return StatusRecord(
      id: json["id"].toString(),
      heartRate: json["heartRate"],
      tremorFrequency: json["tremorFrequency"],
      datetime: json["date"] as String,
      sleepDuration: (json["sleepHours"] as num?)?.toDouble() ?? 0.0,
      pulse: (json["pulse"] as num).toInt(),
      sleepQuality: json["sleepQuality"] as String,
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List<StatusRecord> _statusRecords = [];
  Timer? _dataPageTimer;

  void _getDataWithin14Days() async {
    // 1. 先判断页面是否已销毁，避免异步请求完成后上下文失效（真机上更易出现）
    if (!mounted) return;

    var res = await HttpUtil().get("/health/weekdata");

    // 2. 先判断 res 和 data 不为空，避免空指针导致后续逻辑不执行（真机上容错性更低）
    if (res == null || res["data"] == null || res["data"] is! List) {
      return;
    }

    // 3. 数据解析（保持不变）
    List<StatusRecord> newData = (res["data"] as List<dynamic>)
        .map((record) => StatusRecord.fromJson(record))
        .toList();

    // 4. 确保在 setState 内部更新状态（原子性操作，避免真机异步调度差异）
    if (mounted) {
      // 再次判断上下文有效
      setState(() {
        _statusRecords = newData; // 仅在 setState 内部赋值，确保触发重建
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getDataWithin14Days();

    // _dataPageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
    //   _getDataWithin14Days();
    // });
  }

  @override
  void dispose() {
    _dataPageTimer?.cancel();
    super.dispose();
  }

  double _getWeekAvgHeartRate() {
    if (_statusRecords.isEmpty) return 0.0;
    num val = 0;
    for (var element in _statusRecords) {
      val += element.heartRate;
    }
    return val / _statusRecords.length;
  }

  double _getWeekAvgSleep() {
    if (_statusRecords.isEmpty) return 0.0;
    double val = 0;
    for (var element in _statusRecords) {
      val += element.sleepDuration;
    }
    return val / _statusRecords.length;
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
                Text("数据", style: ShadTheme.of(context).textTheme.h3),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: StatisticCard(
                        title: "本周平均心率",
                        value: _getWeekAvgHeartRate().toStringAsFixed(1),
                        icon: Icons.favorite,
                        color: const Color(0xFFE53E3E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticCard(
                        title: "本周平均睡眠",
                        value: _getWeekAvgSleep().toStringAsFixed(1),
                        icon: Icons.bedtime,
                        color: const Color(0xFF4299E1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "近14天数据",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: _statusRecords
                          .map((e) => _Card.from(e))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final DateTime datetime;
  final String recordId;
  final num heartRate;
  final num pulse;
  final num sleepDuration;
  final num tremorFrequency;

  _Card({
    required this.recordId,
    DateTime? datetime,
    this.heartRate = -1,
    this.pulse = -1,
    this.sleepDuration = -1,
    this.tremorFrequency = -1,
  }) : datetime = datetime ?? DateTime.now();

  factory _Card.from(StatusRecord record) {
    return _Card(
      recordId: record.id,
      datetime: record.datetime,
      heartRate: record.heartRate,
      pulse: record.pulse,
      sleepDuration: record.sleepDuration.toDouble(),
      tremorFrequency: record.tremorFrequency,
    );
  }

  String _formatData(dynamic data) {
    if (data is int && data == -1) return "未记录";
    if (data is double && data == -1) return "未记录";
    if (data is double) return data.toStringAsFixed(1);
    if (data is int) {
      return "$data ${data == heartRate || data == pulse ? "次/分" : "次/小时"}";
    }
    return data.toString();
  }

  Widget _buildDataItem(IconData icon, String title, dynamic value) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                _formatData(value),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDatetime =
        "${datetime.year}/${datetime.month.toString().padLeft(2, '0')}/${datetime.day.toString().padLeft(2, '0')} ";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDatetime,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                recordId,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDataItem(Icons.favorite, "心率", heartRate),
              _buildDataItem(Icons.accessibility, "脉搏", pulse),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDataItem(Icons.bedtime, "睡眠时长", sleepDuration),
              _buildDataItem(Icons.waves, "震颤频率", tremorFrequency),
            ],
          ),
        ],
      ),
    );
  }
}
