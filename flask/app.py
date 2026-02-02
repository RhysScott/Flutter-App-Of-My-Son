import json
import random
from datetime import datetime, timedelta

from flask_cors import CORS
from peewee import CharField, IntegerField, Model, SqliteDatabase, TextField

from flask import Flask, jsonify, request

db = SqliteDatabase("../data.db")


def daily_random(seed, min_val, max_val, precision=1):
    rng = random.Random(seed)
    return round(rng.uniform(min_val, max_val), precision)


def create_response(code, message, data=None):
    return jsonify({
        "code": code,
        "message": message,
        "data": data
    })


def get_uid():
    uid = request.args.get("user_id")
    if not uid or not uid.isdigit():
        return None
    return int(uid)


# ======================= Models =======================

class UserModel(Model):
    phone = CharField(unique=True)
    password = CharField()
    name = CharField()
    age = IntegerField()
    gender = CharField()
    blood_type = CharField()

    class Meta:
        database = db
        table_name = "users"


class ProfileModel(Model):
    uid = IntegerField(unique=True)
    name = CharField()
    age = IntegerField()
    gender = CharField()
    tag = CharField()
    emergency_name = CharField()
    emergency_phone = CharField()
    current_address = CharField()

    class Meta:
        database = db
        table_name = "profiles"


class MedicineRemindModel(Model):
    uid = IntegerField()
    name = CharField()
    time = CharField()
    desc = CharField()

    class Meta:
        database = db
        table_name = "medicine_reminds"


class WeekDataModel(Model):
    uid = IntegerField()
    date = CharField()
    tremor_frequency = IntegerField()
    sleep_hours = IntegerField()
    sleep_quality = CharField()
    heart_rate = IntegerField()
    pulse = IntegerField()

    class Meta:
        database = db
        table_name = "week_data"


class MedicalRecordModel(Model):
    record_id = CharField(unique=True)
    uid = IntegerField()
    patient_name = CharField()
    age = IntegerField()
    gender = CharField()
    record_time = CharField()
    chief_complaint = CharField()
    diagnosis_result = CharField()
    check_items_json = TextField(default="[]")

    class Meta:
        database = db
        table_name = "medical_records"


# ======================= App =======================

app = Flask(__name__)
CORS(app, supports_credentials=True)


@app.before_request
def handle_options():
    if request.method == "OPTIONS":
        return "", 200


# ======================= User =======================

@app.route("/api/user/register", methods=["POST"])
def register():
    data = request.get_json() or {}
    phone = data.get("phone")
    password = data.get("password")

    if not phone or not password:
        return create_response(-1, "手机号和密码不能为空", None)

    if UserModel.get_or_none(UserModel.phone == phone):
        return create_response(-2, "手机号已注册", None)

    user = UserModel.create(
        phone=phone,
        password=password,
        name="新用户",
        age=0,
        gender="未知",
        blood_type="未知"
    )

    return create_response(200, "注册成功", {
        "token": str(user.id),
        "user": {
            "user_id": user.id,
            "phone": user.phone
        }
    })


@app.route("/api/user/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    phone = data.get("phone")
    password = data.get("password")

    user = UserModel.get_or_none(UserModel.phone == phone)
    if not user or user.password != password:
        return create_response(-1, "手机号或密码错误", None)

    return create_response(200, "登录成功", {
        "token": str(user.id),
        "user": {
            "user_id": user.id,
            "name": user.name,
            "phone": user.phone,
            "age": user.age,
            "gender": user.gender,
            "blood_type": user.blood_type
        }
    })


# ======================= Profile（含用药提醒） =======================

@app.route("/api/user/profile", methods=["GET"])
def get_profile():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    user = UserModel.get_or_none(UserModel.id == uid)
    if not user:
        return create_response(-404, "用户不存在", None)

    profile, _ = ProfileModel.get_or_create(
        uid=uid,
        defaults={
            "name": user.name,
            "age": user.age,
            "gender": user.gender,
            "tag": "无",
            "emergency_name": "",
            "emergency_phone": "",
            "current_address": ""
        }
    )

    reminds = MedicineRemindModel.select().where(
        MedicineRemindModel.uid == uid
    )

    medicine_reminds = [
        {
            "name": r.name,
            "time": r.time,
            "desc": r.desc
        } for r in reminds
    ]

    return create_response(200, "获取个人信息成功", {
        "name": profile.name,
        "age": profile.age,
        "gender": profile.gender,
        "tag": profile.tag,
        "emergencyName": profile.emergency_name,
        "emergencyPhone": profile.emergency_phone,
        "currentAddress": profile.current_address,
        "medicineReminds": medicine_reminds
    })


@app.route("/api/user/profile", methods=["POST"])
def update_profile():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    data = request.get_json() or {}
    profile, _ = ProfileModel.get_or_create(uid=uid)

    mapping = {
        "name": "name",
        "age": "age",
        "gender": "gender",
        "tag": "tag",
        "emergencyName": "emergency_name",
        "emergencyPhone": "emergency_phone",
        "currentAddress": "current_address"
    }

    for k, v in mapping.items():
        if k in data:
            setattr(profile, v, data[k])

    profile.save()
    return create_response(200, "更新成功", None)


# ======================= Health =======================

@app.route("/api/health", methods=["GET"])
def health():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    today = datetime.today().strftime("%Y-%m-%d")

    tremor = int(daily_random(f"{uid}_{today}_t", 8, 12))
    sleep_hours = daily_random(f"{uid}_{today}_s", 4, 10)
    sleep_quality = random.choice(["Good", "Average", "Poor"])
    heart_rate = int(daily_random(f"{uid}_{today}_h", 65, 110))
    pulse = int(daily_random(f"{uid}_{today}_p", 68, 110))

    WeekDataModel.get_or_create(
        uid=uid,
        date=today,
        defaults={
            "tremor_frequency": tremor,
            "sleep_hours": sleep_hours,
            "sleep_quality": sleep_quality,
            "heart_rate": heart_rate,
            "pulse": pulse
        }
    )

    return create_response(200, "获取成功", {
        "tremorFrequency": tremor,
        "sleepHours": sleep_hours,
        "sleepQuality": sleep_quality,
        "heartRate": heart_rate,
        "pulse": pulse,
        "date": today
    })


# ======================= Medical Record =======================

@app.route("/api/user/medical/record/add", methods=["POST"])
def add_medical_record():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    data = request.get_json() or {}
    try:
        check_items_json = json.dumps(data.get("checkItems", []))
    except Exception:
        check_items_json = "[]"

    record = MedicalRecordModel.create(
        record_id=data.get("recordId") or f"MR{int(datetime.now().timestamp())}{uid}",
        uid=uid,
        patient_name=data.get("patientName", ""),
        age=data.get("age", 0),
        gender=data.get("gender", ""),
        record_time=data.get("recordTime") or datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        chief_complaint=data.get("chiefComplaint", ""),
        diagnosis_result=data.get("diagnosisResult", ""),
        check_items_json=check_items_json
    )

    return create_response(200, "新增成功", {
        "recordId": record.record_id
    })


@app.route("/api/user/medical/records", methods=["GET"])
def list_medical_records():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    records = (
        MedicalRecordModel
        .select()
        .where(MedicalRecordModel.uid == uid)
        .order_by(MedicalRecordModel.record_time.desc())
    )

    result = []
    for r in records:
        try:
            check_items = json.loads(r.check_items_json or "[]")
        except Exception:
            check_items = []

        result.append({
            "recordId": r.record_id,
            "patientName": r.patient_name,
            "age": r.age,
            "gender": r.gender,
            "recordTime": r.record_time,
            "chiefComplaint": r.chief_complaint,
            "diagnosisResult": r.diagnosis_result,
            "checkItems": check_items
        })

    return create_response(200, "查询成功", result)


@app.route("/api/user/medical/record/delete", methods=["POST"])
def delete_medical_record():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    data = request.get_json() or {}
    record_id = data.get("recordId")

    if not record_id:
        return create_response(-1, "recordId 不能为空", None)

    record = MedicalRecordModel.get_or_none(
        (MedicalRecordModel.record_id == record_id) &
        (MedicalRecordModel.uid == uid)
    )

    if not record:
        return create_response(-404, "病史不存在", None)

    record.delete_instance()
    return create_response(200, "删除成功", None)


# ======================= Medicine Remind =======================

@app.route("/api/user/medicine/remind/add", methods=["POST"])
def add_medicine_remind():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    data = request.get_json() or {}
    if not data.get("name") or not data.get("time"):
        return create_response(-1, "参数不完整", None)

    remind = MedicineRemindModel.create(
        uid=uid,
        name=data["name"],
        time=data["time"],
        desc=data.get("desc", "")
    )

    return create_response(200, "新增成功", {
        "id": remind.id
    })


@app.route("/api/user/medicine/remind/delete", methods=["POST"])
def delete_medicine_remind():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    data = request.get_json() or {}
    remind_id = data.get("id")

    if not remind_id:
        return create_response(-1, "id 不能为空", None)

    remind = MedicineRemindModel.get_or_none(
        (MedicineRemindModel.id == remind_id) &
        (MedicineRemindModel.uid == uid)
    )

    if not remind:
        return create_response(-404, "提醒不存在", None)

    remind.delete_instance()
    return create_response(200, "删除成功", None)

@app.route("/api/health/weekdata", methods=["GET"])
def get_week_data():
    uid = get_uid()
    if not uid:
        return create_response(-401, "未登录", None)

    days = int(request.args.get("days", 14))

    records = (
        WeekDataModel
        .select()
        .where(WeekDataModel.uid == uid)
        .order_by(WeekDataModel.date.desc())
        .limit(days)
    )

    result = []
    index = 1

    for r in records:
        result.append({
            "id": f"DAY {index:02d}",
            "date": r.date,
            "tremorFrequency": float(r.tremor_frequency),
            "sleepHours": float(r.sleep_hours),
            "sleepQuality": r.sleep_quality,
            "heartRate": float(r.heart_rate),
            "pulse": float(r.pulse)
        })
        index += 1

    return create_response(200, "查询近{}天数据成功".format(len(result)), result)


# ======================= Start =======================

if __name__ == "__main__":
    db.connect()
    db.create_tables(
        [
            UserModel,
            ProfileModel,
            MedicineRemindModel,
            WeekDataModel,
            MedicalRecordModel
        ],
        safe=True
    )
    app.run(host="0.0.0.0", port=8080, debug=True)
