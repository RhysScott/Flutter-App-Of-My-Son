class CheckItemModel {
  final String itemName;
  final String result;
  final String referenceRange;
  final String unit;
  const CheckItemModel({
    required this.itemName,
    required this.result,
    required this.referenceRange,
    required this.unit,
  });

  factory CheckItemModel.fromJson(Map<String, dynamic> json) {
    return CheckItemModel(
      itemName: json["itemName"] ?? "",
      result: json["result"] ?? "",
      referenceRange: json["referenceRange"] ?? "",
      unit: json["unit"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "itemName": itemName,
      "result": result,
      "referenceRange": referenceRange,
      "unit": unit,
    };
  }
}

class MedicalRecordModel {
  final String recordId;
  final String patientName;
  final int age;
  final String gender;
  final String recordTime;
  final String chiefComplaint;
  final String diagnosisResult;
  final List<CheckItemModel> checkItems;

  const MedicalRecordModel({
    required this.recordId,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.recordTime,
    required this.chiefComplaint,
    required this.diagnosisResult,
    required this.checkItems,
  });

  MedicalRecordModel copyWith({
    String? recordId,
    String? patientName,
    int? age,
    String? gender,
    String? recordTime,
    String? chiefComplaint,
    String? diagnosisResult,
    List<CheckItemModel>? checkItems,
  }) {
    return MedicalRecordModel(
      recordId: recordId ?? this.recordId,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      recordTime: recordTime ?? this.recordTime,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      diagnosisResult: diagnosisResult ?? this.diagnosisResult,
      checkItems: checkItems ?? this.checkItems,
    );
  }

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    List<CheckItemModel> checkItems =
        (json["checkItems"] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((item) => CheckItemModel.fromJson(item))
            .toList() ??
        [];

    return MedicalRecordModel(
      recordId: json["recordId"] ?? "",
      patientName: json["patientName"] ?? "",
      age: json["age"] ?? 0,
      gender: json["gender"] ?? "",
      recordTime: json["recordTime"] ?? "",
      chiefComplaint: json["chiefComplaint"] ?? "",
      diagnosisResult: json["diagnosisResult"] ?? "",
      checkItems: checkItems,
    );
  }

  // 转换为 JSON（本地模型 → 提交服务器）
  Map<String, dynamic> toJson() {
    return {
      "recordId": recordId,
      "patientName": patientName,
      "age": age,
      "gender": gender,
      "recordTime": recordTime,
      "chiefComplaint": chiefComplaint,
      "diagnosisResult": diagnosisResult,
      "checkItems": checkItems.map((item) => item.toJson()).toList(),
    };
  }
}

class MedicineRemindModel {
  final String name;
  final String time;
  final String desc;
  const MedicineRemindModel({
    required this.name,
    required this.time,
    required this.desc,
  });
  factory MedicineRemindModel.fromJson(Map<String, dynamic> json) {
    return MedicineRemindModel(
      name: json["name"] ?? "未知药品",
      time: json["time"] ?? "未知时间",
      desc: json["desc"] ?? "无备注",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "time": time,
      "desc": desc,
      // 可选："uid": uid, // 若需要传递用户ID，后续可从 LocalStorage 获取补充
    };
  }
}

class BasicHistoryModel {
  final String bloodType;
  final List<String> basicHistories;
  const BasicHistoryModel({
    required this.bloodType,
    required this.basicHistories,
  });
}

class WeekDataModel {
  final String date;
  final int tremorFrequency;
  final int sleepHours;
  final String sleepQuality;
  final int heartRate;
  final int pulse;
  const WeekDataModel({
    required this.date,
    required this.tremorFrequency,
    required this.sleepHours,
    required this.sleepQuality,
    required this.heartRate,
    required this.pulse,
  });
}
