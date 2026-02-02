import json
import random
from datetime import datetime, timedelta

from flask_cors import CORS
from flask_jwt_extended import (JWTManager, create_access_token,
                                get_jwt_identity, jwt_required)
from peewee import CharField, IntegerField, Model, SqliteDatabase, TextField

from flask import Flask, jsonify, request

db = SqliteDatabase('data.db')

def daily_random(seed, min_val, max_val, precision=1):
    rng = random.Random(seed)
    return round(rng.uniform(min_val, max_val), precision)


def create_response(code, message, data=None):
    return jsonify({
        "code": code,
        "message": message,
        "data": data or {}
    })

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
        table_name = 'profiles'


class UserModel(Model):
    phone = CharField(unique=True)
    password = CharField()
    name = CharField()
    age = IntegerField()
    gender = CharField()
    blood_type = CharField()

    class Meta:
        database = db
        table_name = 'users'


class CheckItemModel(Model):
    item_name = CharField()
    result = CharField()
    reference_range = CharField()
    unit = CharField()

    class Meta:
        database = db
        table_name = 'check_items'


class MedicalRecordModel(Model):
    record_id = CharField(unique=True)
    uid = IntegerField()
    patient_name = CharField()
    age = IntegerField()
    gender = CharField()
    record_time = CharField()
    chief_complaint = CharField()
    diagnosis_result = CharField()
    check_items_json = TextField(default='[]')

    class Meta:
        database = db
        table_name = 'medical_records'


class MedicineRemindModel(Model):
    uid = IntegerField()
    name = CharField()
    time = CharField()
    desc = CharField()

    class Meta:
        database = db
        table_name = 'medicine_reminds'


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
        table_name = 'week_data'

app = Flask(__name__)
CORS(app)

app.config["JWT_SECRET_KEY"] = "change-this-secret"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(days=7)
app.config['JWT_CSRF_IN_TOKENS'] = False

jwt = JWTManager(app)

@app.route("/api/user/register", methods=["POST"])
def user_register():
    data = request.get_json() or {}
    phone = data.get("phone")
    password = data.get("password")

    if not phone or not password:
        return create_response(-1, "手机号和密码不能为空")

    if UserModel.get_or_none(UserModel.phone == phone):
        return create_response(-2, "手机号已注册")

    user = UserModel.create(
        phone=phone,
        password=password,
        name="新用户",
        age=0,
        gender="未知",
        blood_type="未知"
    )

    token = create_access_token(identity=str(user.id))
    print(f"注册用户: {user.id}, phone: {phone}, token: {token}")

    return create_response(200, "注册成功", {
        "token": token,
        "user": {
            "user_id": user.id,
            "phone": user.phone
        }
    })


@app.route("/api/user/login", methods=["POST"])
def user_login():
    data = request.get_json() or {}
    phone = data.get("phone")
    password = data.get("password")

    user = UserModel.get_or_none(UserModel.phone == phone)
    if not user or user.password != password:
        return create_response(-1, "手机号或密码错误")

    token = create_access_token(identity=str(user.id))
    print(f"登录用户: {user.id}, phone: {phone}, name: {user.name}, age: {user.age}, gender: {user.gender}, blood_type: {user.blood_type}, token: {token}")

    return create_response(200, "登录成功", {
        "token": token,
        "user": {
            "user_id": user.id,
            "name": user.name,
            "phone": user.phone,
            "age": user.age,
            "gender": user.gender,
            "blood_type": user.blood_type
        }
    })

@app.route("/api/health", methods=["GET"])
@jwt_required()
def mock_health_data():
    uid = get_jwt_identity()
    today = datetime.today().strftime('%Y-%m-%d')

    sleep_quality_options = ['Good', 'Average', 'Poor']

    tremor_frequency = int(daily_random(f"{uid}_{today}_t", 8, 12))
    sleep_hours = daily_random(f"{uid}_{today}_s", 4, 12, 1)
    sleep_quality = sleep_quality_options[
        int(daily_random(f"{uid}_{today}_q", 0, 2))
    ]
    heart_rate = int(daily_random(f"{uid}_{today}_h", 65, 120))
    pulse = int(daily_random(f"{uid}_{today}_p", 68, 120))

    row = WeekDataModel.get_or_none(
        (WeekDataModel.uid == uid) &
        (WeekDataModel.date == today)
    )

    if row:
        row.tremor_frequency = tremor_frequency
        row.sleep_hours = sleep_hours
        row.sleep_quality = sleep_quality
        row.heart_rate = heart_rate
        row.pulse = pulse
        row.save()
    else:
        WeekDataModel.create(
            uid=uid,
            date=today,
            tremor_frequency=tremor_frequency,
            sleep_hours=sleep_hours,
            sleep_quality=sleep_quality,
            heart_rate=heart_rate,
            pulse=pulse
        )

    health_data = {
        "tremorFrequency": tremor_frequency,
        "sleepHours": sleep_hours,
        "sleepQuality": sleep_quality,
        "heartRate": heart_rate,
        "pulse": pulse,
        "date": today
    }
    print(f"健康数据 for uid {uid} on {today}: {health_data}")

    return create_response(200, "实时健康数据获取成功", health_data)

@app.route("/api/health/weekdata", methods=["GET"])
@jwt_required()
def get_week_data():
    uid = get_jwt_identity()
    today = datetime.today()
    start_date = (today - timedelta(days=13)).strftime('%Y-%m-%d')

    week_data = (
        WeekDataModel
        .select()
        .where(
            (WeekDataModel.uid == uid) &
            (WeekDataModel.date >= start_date)
        )
    )

    result = []

    for i in range(14):
        date = (today - timedelta(days=i)).strftime('%Y-%m-%d')
        daily_list = list(week_data.where(WeekDataModel.date == date))

        if daily_list:
            count = len(daily_list)
            result.append({
                "id": f"DAY {i+1:02}",
                "date": date,
                "tremorFrequency": round(sum(d.tremor_frequency for d in daily_list) / count, 2),
                "sleepHours": round(sum(d.sleep_hours for d in daily_list) / count, 2),
                "sleepQuality": max(
                    ["Good", "Average", "Poor"],
                    key=lambda q: sum(1 for d in daily_list if d.sleep_quality == q)
                ),
                "heartRate": round(sum(d.heart_rate for d in daily_list) / count, 2),
                "pulse": round(sum(d.pulse for d in daily_list) / count, 2)
            })

    print(f"周健康数据 for uid {uid}: {len(result)} 条记录")

    return create_response(200, "查询健康数据成功", result)

@app.route("/api/user/profile", methods=["GET"])
@jwt_required()
def get_user_profile():
    uid = get_jwt_identity()

    profile = ProfileModel.get_or_none(ProfileModel.uid == uid)
    if not profile:
        return create_response(-1, "档案不存在")

    reminds = MedicineRemindModel.select().where(
        MedicineRemindModel.uid == uid
    )

    profile_data = {
        "name": profile.name,
        "age": profile.age,
        "gender": profile.gender,
        "tag": profile.tag,
        "emergencyName": profile.emergency_name,
        "emergencyPhone": profile.emergency_phone,
        "currentAddress": profile.current_address,
        "medicineReminds": [
            {
                "name": r.name,
                "time": r.time,
                "desc": r.desc
            } for r in reminds
        ]
    }
    print(f"用户档案 for uid {uid}: {profile_data}")

    return create_response(200, "获取档案成功", profile_data)


@app.route("/api/user/profile", methods=["POST"])
@jwt_required()
def update_user_profile():
    uid = get_jwt_identity()
    data = request.get_json() or {}

    profile, created = ProfileModel.get_or_create(
        uid=uid,
        defaults={
            "name": data.get("name", ""),
            "age": data.get("age", 0),
            "gender": data.get("gender", ""),
            "tag": data.get("tag", ""),
            "emergency_name": data.get("emergencyName", ""),
            "emergency_phone": data.get("emergencyPhone", ""),
            "current_address": data.get("currentAddress", "")
        }
    )

    if not created:
        profile.name = data.get("name", profile.name)
        profile.age = data.get("age", profile.age)
        profile.gender = data.get("gender", profile.gender)
        profile.tag = data.get("tag", profile.tag)
        profile.emergency_name = data.get("emergencyName", profile.emergency_name)
        profile.emergency_phone = data.get("emergencyPhone", profile.emergency_phone)
        profile.current_address = data.get("currentAddress", profile.current_address)
        profile.save()

    print(f"更新用户档案 for uid {uid}: {data}")

    return create_response(200, "档案更新成功")


@app.route("/api/user/medical/records", methods=["GET"])
@jwt_required()
def get_medical_records():
    uid = get_jwt_identity()
    records = MedicalRecordModel.select().where(
        MedicalRecordModel.uid == uid
    ).order_by(MedicalRecordModel.record_time.desc())

    result = []
    for record in records:
        try:
            check_items = json.loads(record.check_items_json)
        except:
            check_items = []

        result.append({
            "recordId": record.record_id,
            "patientName": record.patient_name,
            "age": record.age,
            "gender": record.gender,
            "recordTime": record.record_time,
            "chiefComplaint": record.chief_complaint,
            "diagnosisResult": record.diagnosis_result,
            "checkItems": check_items
        })

    print(f"病史列表 for uid {uid}: {len(result)} 条记录")

    return create_response(200, "获取病史列表成功", result)

@app.route("/api/user/medical/record/add", methods=["POST"])
@jwt_required()
def add_medical_record():
    uid = get_jwt_identity()
    data = request.get_json() or {}

    record_id = data.get("recordId")
    patient_name = data.get("patientName")
    age = data.get("age", 0)
    gender = data.get("gender")
    record_time = data.get("recordTime")
    chief_complaint = data.get("chiefComplaint")
    diagnosis_result = data.get("diagnosisResult")

    if not all([record_id, patient_name, gender, record_time, chief_complaint, diagnosis_result]):
        return create_response(-1, "必填字段不能为空")

    check_items = data.get("checkItems", [])
    try:
        check_items_json = json.dumps(check_items)
    except:
        check_items_json = "[]"

    try:
        MedicalRecordModel.create(
            record_id=record_id,
            uid=uid,
            patient_name=patient_name,
            age=int(age),
            gender=gender,
            record_time=record_time,
            chief_complaint=chief_complaint,
            diagnosis_result=diagnosis_result,
            check_items_json=check_items_json
        )
        print(f"新增病史 for uid {uid}: {data}")
        return create_response(200, "病史新增成功")
    except Exception as e:
        print(f"新增病史失败 for uid {uid}: {str(e)}")
        return create_response(-2, f"新增失败：{str(e)}")

@app.route("/api/user/medical/record/edit", methods=["POST"])
@jwt_required()
def edit_medical_record():
    uid = get_jwt_identity()
    data = request.get_json() or {}

    record_id = data.get("recordId")
    if not record_id:
        return create_response(-1, "病史编号不能为空")

    record = MedicalRecordModel.get_or_none(
        (MedicalRecordModel.record_id == record_id) &
        (MedicalRecordModel.uid == uid)
    )
    if not record:
        return create_response(-2, "病史记录不存在")

    record.patient_name = data.get("patientName", record.patient_name)
    record.age = int(data.get("age", record.age))
    record.gender = data.get("gender", record.gender)
    record.record_time = data.get("recordTime", record.record_time)
    record.chief_complaint = data.get("chiefComplaint", record.chief_complaint)
    record.diagnosis_result = data.get("diagnosisResult", record.diagnosis_result)

    check_items = data.get("checkItems")
    if check_items is not None:
        try:
            record.check_items_json = json.dumps(check_items)
        except:
            record.check_items_json = "[]"

    try:
        record.save()
        print(f"编辑病史 for uid {uid}, record_id {record_id}: {data}")
        return create_response(200, "病史编辑成功")
    except Exception as e:
        print(f"编辑病史失败 for uid {uid}: {str(e)}")
        return create_response(-3, f"编辑失败：{str(e)}")

@app.route("/api/user/medical/record/delete", methods=["POST"])
@jwt_required()
def delete_medical_record():
    uid = get_jwt_identity()
    data = request.get_json() or {}

    record_id = data.get("recordId")
    if not record_id:
        return create_response(-1, "病史编号不能为空")

    record = MedicalRecordModel.get_or_none(
        (MedicalRecordModel.record_id == record_id) &
        (MedicalRecordModel.uid == uid)
    )
    if not record:
        return create_response(-2, "病史记录不存在")

    try:
        record.delete_instance()
        print(f"删除病史 for uid {uid}, record_id {record_id}")
        return create_response(200, "病史删除成功")
    except Exception as e:
        print(f"删除病史失败 for uid {uid}: {str(e)}")
        return create_response(-3, f"删除失败：{str(e)}")

@app.route("/api/user/medicine/remind/add", methods=["POST"])
@jwt_required()
def add_medicine_remind():
    uid = get_jwt_identity()
    data = request.get_json() or {}

    name = data.get("name")
    time = data.get("time")
    desc = data.get("desc")

    if not all([name, time]):
        return create_response(-1, "药品名称和提醒时间不能为空")

    try:
        MedicineRemindModel.create(
            uid=uid,
            name=name,
            time=time,
            desc=desc or ""
        )
        print(f"新增用药提醒 for uid {uid}: {data}")
        return create_response(200, "用药提醒新增成功")
    except Exception as e:
        print(f"新增用药提醒失败 for uid {uid}: {str(e)}")
        return create_response(-2, f"新增失败：{str(e)}")

if __name__ == "__main__":
    db.connect()
    db.create_tables([
        UserModel,
        CheckItemModel,
        MedicalRecordModel,
        MedicineRemindModel,
        WeekDataModel,
        ProfileModel
    ], safe=True)
    app.run(host="0.0.0.0", port=8888, debug=True)
