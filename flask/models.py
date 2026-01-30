from peewee import (CharField, DateTimeField, FloatField, IntegerField, Model,
                    PrimaryKeyField, SqliteDatabase, TextField)

db = SqliteDatabase('data.db')

class StatusRecord(Model):

    id = PrimaryKeyField(auto_increment=True)

    heart_rate = IntegerField(default=0, null=False)
    pulse = IntegerField(default=0, null=False)

    sleep_duration = FloatField(default=0.0, null=False)
    tremor_frequency = IntegerField(default=0, null=False)

    datetime = DateTimeField(default=datetime.datetime.now, null=False)
    sleep_quality = TextField(default="unknown", null=False)

    class Meta:
        database = db
        table_name = 'status_records'


    def __init__(self, heart_rate=None, pulse=None, sleep_duration=None,
                 tremor_frequency=None, sleep_quality=None, datetime=None, **kwargs):
        super().__init__(**kwargs)
        self.heart_rate = heart_rate or 0
        self.pulse = pulse or 0
        self.sleep_duration = sleep_duration or 0.0
        self.tremor_frequency = tremor_frequency or 0
        self.sleep_quality = sleep_quality or "unknown"
        self.datetime = datetime or datetime.datetime.now()

    def to_dict(self):
        return {
            "id": self.id,
            "heart_rate": self.heart_rate,
            "pulse": self.pulse,
            "sleep_duration": self.sleep_duration,
            "tremor_frequency": self.tremor_frequency,
            "datetime": self.datetime.isoformat(),
            "sleep_quality": self.sleep_quality
        }

class CheckItem:
    def __init__(self, item_name=None, result=None, reference_range=None, unit=None):
        self.item_name = item_name or ""
        self.result = result or ""
        self.reference_range = reference_range or ""
        self.unit = unit or ""

    def to_dict(self):
        return {
            "itemName": self.item_name,
            "result": self.result,
            "referenceRange": self.reference_range,
            "unit": self.unit
        }

class MedicalRecord:
    def __init__(self, record_id=None, age=None, gender=None, record_time=None, chief_complaint=None, diagnosis_result=None, check_items=None):
        self.record_id = record_id or ""
        self.age = age or 0
        self.gender = gender or ""
        self.record_time = record_time or ""
        self.chief_complaint = chief_complaint or ""
        self.diagnosis_result = diagnosis_result or ""
        self.check_items = [CheckItem(
            item_name=item.get("itemName"),
            result=item.get("result"),
            reference_range=item.get("referenceRange"),
            unit=item.get("unit")
        ) for item in check_items or []]

    def to_dict(self):
        return {
            "id": self.record_id,
            "age": self.age,
            "gender": self.gender,
            "recordTime": self.record_time,
            "chiefComplaint": self.chief_complaint,
            "diagnosisResult": self.diagnosis_result,
            "checkItems": [item.to_dict() for item in self.check_items]
        }

class User:
    def __init__(self, user_id=None, phone=None, password=None, name=None, age=None, gender=None, blood_type=None):
        self.user_id = user_id or 0
        self.phone = phone or ""
        self.password = password or ""
        self.name = name or ""
        self.age = age or 0
        self.gender = gender or ""
        self.blood_type = blood_type or ""

    def to_dict(self):
        return {
            "id": self.user_id,
            "phone": self.phone,
            "password": self.password,
            "name": self.name,
            "age": self.age,
            "gender": self.gender,
            "blood_type": self.blood_type
        }

class MedicineRemind(Model):
    name = CharField(default="")
    time = CharField(default="")
    desc = CharField(default="")

    class Meta:
        database = db
        table_name = 'medicine_reminds'

    def __init__(self, name=None, time=None, desc=None, **kwargs):
        super().__init__(**kwargs)
        self.name = name or ""
        self.time = time or ""
        self.desc = desc or ""

    def to_dict(self):
        return {
            "name": self.name,
            "time": self.time,
            "desc": self.desc
        }
