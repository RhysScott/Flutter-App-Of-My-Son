import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SleepOverallData {
  final String date;
  final int score;
  final String scoreDesc;
  final String scoreRank;
  final String sleepType;
  final String sleepDuration;
  final String dataSource;
  final List<SleepStageDetail> stageDetails;
  final double deepSleepPercent;
  final String deepSleepDuration;
  final double lightSleepPercent;
  final String lightSleepDuration;
  final int avgHeartRate;
  final int avgBloodOxygen;

  SleepOverallData({
    required this.date,
    required this.score,
    required this.scoreDesc,
    required this.scoreRank,
    required this.sleepType,
    required this.sleepDuration,
    required this.dataSource,
    required this.stageDetails,
    required this.deepSleepPercent,
    required this.deepSleepDuration,
    required this.lightSleepPercent,
    required this.lightSleepDuration,
    required this.avgHeartRate,
    required this.avgBloodOxygen,
  });

  factory SleepOverallData.fromMock() {
    var now = DateTime.now();
    return SleepOverallData(
      date: "${now.year}年${now.month}月${now.day}日",
      score: 71,
      scoreDesc: '睡眠质量一般',
      scoreRank: '超过了43%的同龄用户',
      sleepType: '长睡眠',
      sleepDuration: '3小时17分钟',
      dataSource: 'REDMI Watch 5',
      stageDetails: [
        SleepStageDetail(time: '14:25', deepSleep: 0, lightSleep: 40),
        SleepStageDetail(time: '15:00', deepSleep: 0, lightSleep: 35),
        SleepStageDetail(time: '15:35', deepSleep: 25, lightSleep: 20),
        SleepStageDetail(time: '16:10', deepSleep: 30, lightSleep: 15),
        SleepStageDetail(time: '16:45', deepSleep: 25, lightSleep: 20),
        SleepStageDetail(time: '17:20', deepSleep: 0, lightSleep: 35),
        SleepStageDetail(time: '17:42', deepSleep: 0, lightSleep: 40),
      ],
      deepSleepPercent: 23,
      deepSleepDuration: '45分',
      lightSleepPercent: 77,
      lightSleepDuration: '2时32分',
      avgHeartRate: 61,
      avgBloodOxygen: 96,
    );
  }
}

class SleepStageDetail {
  final String time;
  final int deepSleep;
  final int lightSleep;

  SleepStageDetail({
    required this.time,
    required this.deepSleep,
    required this.lightSleep,
  });
}

class SleepDataPage extends StatefulWidget {
  const SleepDataPage({super.key});

  @override
  State<SleepDataPage> createState() => _SleepDataPageState();
}

class _SleepDataPageState extends State<SleepDataPage> {
  late SleepOverallData _sleepData;

  @override
  void initState() {
    super.initState();
    _sleepData = SleepOverallData.fromMock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text("睡眠质量", style: ShadTheme.of(context).textTheme.h3),
            ),
            _buildDateSelector(),
            const SizedBox(height: 24),
            _buildScoreCard(),
            const SizedBox(height: 20),
            _buildDurationAndStageCard(),
            const SizedBox(height: 20),
            _buildSleepStructureCard(),
            const SizedBox(height: 20),
            _buildVitalSignsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _sleepData.date,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF8FF), Color(0xFFF5F9FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF475467).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _sleepData.scoreDesc,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF98A2B3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _sleepData.score.toString(),
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '分',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1D2939),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_sleepData.scoreRank}！',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF475467).withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '26/1/31\n生成',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF98A2B3),
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationAndStageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF475467).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF8FF),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(
                  Icons.bedtime,
                  color: Color(0xFF2F80ED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _sleepData.sleepType,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _sleepData.sleepDuration,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '数据来源: ${_sleepData.dataSource}',
            style: TextStyle(
              color: const Color(0xFF98A2B3),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildLegendItem(const Color(0xFF1E40AF), '深睡'),
              const SizedBox(width: 24),
              _buildLegendItem(const Color(0xFF2F80ED), '浅睡'),
            ],
          ),
          const SizedBox(height: 16),
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            margin: const EdgeInsets.all(0),
            primaryXAxis: CategoryAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
              labelStyle: const TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              labelPlacement: LabelPlacement.onTicks,
            ),
            primaryYAxis: NumericAxis(isVisible: false, maximum: 40),
            series: <CartesianSeries<SleepStageDetail, String>>[
              StackedColumnSeries<SleepStageDetail, String>(
                dataSource: _sleepData.stageDetails,
                xValueMapper: (SleepStageDetail data, _) => data.time,
                yValueMapper: (SleepStageDetail data, _) => data.deepSleep,
                color: const Color(0xFF1E40AF),
                borderWidth: 0,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              StackedColumnSeries<SleepStageDetail, String>(
                dataSource: _sleepData.stageDetails,
                xValueMapper: (SleepStageDetail data, _) => data.time,
                yValueMapper: (SleepStageDetail data, _) => data.lightSleep,
                color: const Color(0xFF2F80ED),
                borderWidth: 0,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepStructureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF475467).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '睡眠结构',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: SfCircularChart(
                annotations: <CircularChartAnnotation>[
                  CircularChartAnnotation(
                    widget: Text(
                      _sleepData.sleepDuration.replaceAll('分钟', '分'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                  ),
                ],
                series: <CircularSeries>[
                  DoughnutSeries<Map<String, dynamic>, String>(
                    dataSource: [
                      {
                        'name': '深睡',
                        'value': _sleepData.deepSleepPercent,
                        'color': const Color(0xFF1E40AF),
                      },
                      {
                        'name': '浅睡',
                        'value': _sleepData.lightSleepPercent,
                        'color': const Color(0xFF2F80ED),
                      },
                    ],
                    xValueMapper: (data, _) => data['name'],
                    yValueMapper: (data, _) => data['value'],
                    pointColorMapper: (data, _) => data['color'],
                    radius: '85%',
                    innerRadius: '70%',
                    strokeWidth: 0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              _buildSleepDetailItem(
                '浅睡',
                _sleepData.lightSleepPercent,
                '参考: 60%-80%',
                _sleepData.lightSleepDuration,
                const Color(0xFF2F80ED),
              ),
              const SizedBox(height: 16),
              _buildSleepDetailItem(
                '深睡',
                _sleepData.deepSleepPercent,
                '参考: 20%-40%',
                _sleepData.deepSleepDuration,
                const Color(0xFF1E40AF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepDetailItem(
    String title,
    double percent,
    String reference,
    String duration,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F7), width: 1)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percent.toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
              Text(
                reference,
                style: TextStyle(
                  color: const Color(0xFF98A2B3),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF475467).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildVitalSignItem('睡眠平均心率', '${_sleepData.avgHeartRate}次/分'),
          _buildVitalSignItem('睡眠平均血氧', '${_sleepData.avgBloodOxygen}%'),
        ],
      ),
    );
  }

  Widget _buildVitalSignItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F7), width: 1)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D2939),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
