import datetime
from random import randint

from flask_cors import CORS

from flask import Flask, jsonify, request

app = Flask(__name__)
CORS(app)

mock_users = {
    "13800138000": {
        "id": 1,
        "phone": "13800138000",
        "password": "123456",
        "name": "小朋友",
        "age": 65,
        "gender": "男",
        "blood_type": "A型",
    }
}

# 2. 模拟病史记录（对应 MedicalRecordModel、CheckItemModel）
mock_medical_records = [
    {
        "recordId": "REC001",
        "age": 65,
        "gender": "男",
        "recordTime": "2026-01-20 09:30:00",
        "chiefComplaint": "近期手部震颤频率略有升高，晨起头晕",
        "diagnosisResult": "继续按原剂量服用美多巴和硝苯地平，避免劳累，保证睡眠，1周后复诊",
        "checkItems": [
            {
                "itemName": "心率",
                "result": "78",
                "referenceRange": "60-100",
                "unit": "BPM"
            },
            {
                "itemName": "震颤频率",
                "result": "3",
                "referenceRange": "0-4",
                "unit": "Hz"
            },
            {
                "itemName": "血压",
                "result": "145/90",
                "referenceRange": "90/60-130/80",
                "unit": "mmHg"
            }
        ]
    },
    {
        "recordId": "REC002",
        "age": 65,
        "gender": "男",
        "recordTime": "2026-01-10 10:00:00",
        "chiefComplaint": "睡眠质量差，每晚仅睡5小时，服药后震颤缓解",
        "diagnosisResult": "添加助眠片，睡前半小时服用半片，观察睡眠情况，调整用药周期",
        "checkItems": [
            {
                "itemName": "心率",
                "result": "75",
                "referenceRange": "60-100",
                "unit": "BPM"
            },
            {
                "itemName": "震颤频率",
                "result": "2",
                "referenceRange": "0-4",
                "unit": "Hz"
            },
            {
                "itemName": "睡眠时长",
                "result": "5",
                "referenceRange": "7-9",
                "unit": "小时"
            }
        ]
    },
    {
        "recordId": "REC003",
        "age": 65,
        "gender": "男",
        "recordTime": "2026-01-01 09:00:00",
        "chiefComplaint": "确诊帕金森轻度1个月，血压控制尚可",
        "diagnosisResult": "开始服用美多巴（08:00饭前）、硝苯地平（18:00饭后），定期监测震颤和血压",
        "checkItems": [
            {
                "itemName": "心率",
                "result": "72",
                "referenceRange": "60-100",
                "unit": "BPM"
            },
            {
                "itemName": "震颤频率",
                "result": "1",
                "referenceRange": "0-4",
                "unit": "Hz"
            },
            {
                "itemName": "血压",
                "result": "135/85",
                "referenceRange": "90/60-130/80",
                "unit": "mmHg"
            }
        ]
    }
]

# 3. 模拟用药提醒（对应 MedicineRemindModel）
mock_medicine_reminds = [
    {
        "name": "美多巴（帕金森）",
        "time": "08:00",
        "desc": "饭前30分钟，1片/次"
    },
    {
        "name": "硝苯地平（高血压）",
        "time": "18:00",
        "desc": "饭后，1片/次"
    },
    {
        "name": "助眠片",
        "time": "21:30",
        "desc": "睡前服用，半片/次"
    }
]

# 4. 模拟每周健康数据（对应 WeekDataModel）
mock_week_data = []

# 循环生成近14天数据（从今天往前推13天，共14天）
for i in range(14):
    # 核心：日期递减，每次循环减去 i 天
    current_date = datetime.datetime.now() - datetime.timedelta(days=i)
    # 格式1：ISO 8601格式（推荐，Flutter DateTime.parse() 可直接解析）
    date_str = current_date.isoformat()
    # 格式2：如果需要自定义格式（比如 "2026-01-29 15:30:00"），可使用 strftime
    # date_str = current_date.strftime("%Y-%m-%d %H:%M:%S")

    mock_week_data.append({
        # 字段名对应Flutter接口，改为下划线命名
        "id": f"record_{i:02d}",  # 补充唯一ID，对应Flutter的 id 字段
        "datetime": date_str,      # 修正日期字段名和格式
        "tremor_frequency": (i % 5) + 1,  # 修正为下划线命名
        "sleep_duration": (i % 5) + 6,    # 对应Flutter的 sleep_duration
        "sleep_quality": "优" if (i % 3) == 0 else "良" if (i % 3) == 1 else "差",
        "heart_rate": (i % 30) + 65,      # 对应Flutter的 heart_rate
        "pulse": (i % 30) + 65            # 对应Flutter的 pulse
    })

# 5. 模拟客服消息记录
mock_service_messages = [
    {
        "text": "您好！我是您的专属健康客服，工作日9:00-18:00在线~",
        "isUser": False,
        "time": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
]

# ---------------------- 核心接口（对应 Flutter 前端所有功能）----------------------
# 1. 登录接口（POST）
@app.route("/api/user/login", methods=["POST"])
def user_login():
    try:
        # 获取前端传递的 JSON 数据
        request_data = request.get_json()
        phone = request_data.get("phone")
        password = request_data.get("password")

        # 参数校验
        if not phone or not password:
            return jsonify({
                "code": -1,
                "message": "手机号和密码不能为空",
                "data": None
            })

        # 验证用户
        user = mock_users.get(phone)
        if not user:
            return jsonify({
                "code": -2,
                "message": "用户不存在",
                "data": None
            })

        if user["password"] != password:
            return jsonify({
                "code": -3,
                "message": "密码错误",
                "data": None
            })

        # 登录成功，返回用户核心信息
        return jsonify({
            "code": 200,
            "message": "登录成功",
            "data": {
                "user_id": user["id"],
                "name": user["name"],
                "phone": user["phone"],
                "age": user["age"],
                "gender": user["gender"],
                "blood_type": user["blood_type"],
                "basic_histories": user["basic_histories"]
            }
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# 2. 获取病史列表接口（GET）
@app.route("/api/medical/records", methods=["GET"])
def get_medical_records():
    try:
        return jsonify({
            "code": 200,
            "message": "查询病史列表成功",
            "data": mock_medical_records
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# 3. 获取单个病史详情接口（GET）
@app.route("/api/medical/record/detail", methods=["GET"])
def get_medical_record_detail():
    try:
        # 获取 URL 参数中的 recordId
        record_id = request.args.get("recordId")
        if not record_id:
            return jsonify({
                "code": -1,
                "message": "病史ID不能为空",
                "data": None
            })

        # 查找对应病史
        record = None
        for r in mock_medical_records:
            if r["recordId"] == record_id:
                record = r
                break

        if not record:
            return jsonify({
                "code": -2,
                "message": "病史不存在",
                "data": None
            })

        return jsonify({
            "code": 200,
            "message": "查询病史详情成功",
            "data": record
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# 4. 获取用药提醒列表接口（GET）
@app.route("/api/medicine/reminds", methods=["GET"])
def get_medicine_reminds():
    try:
        return jsonify({
            "code": 200,
            "message": "查询用药提醒成功",
            "data": mock_medicine_reminds
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# 5. 新增用药提醒接口（POST）
@app.route("/api/medicine/remind/add", methods=["POST"])
def add_medicine_remind():
    try:
        request_data = request.get_json()
        name = request_data.get("name")
        time = request_data.get("time")
        desc = request_data.get("desc")

        if not name or not time:
            return jsonify({
                "code": -1,
                "message": "药品名称和服药时间不能为空",
                "data": None
            })

        new_remind = {
            "name": name,
            "time": time,
            "desc": desc or ""
        }
        mock_medicine_reminds.append(new_remind)

        return jsonify({
            "code": 200,
            "message": "新增用药提醒成功",
            "data": new_remind
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# 6. 获取近14天健康数据接口（GET）
@app.route("/api/health/weekdata", methods=["GET"])
def get_week_data():
    try:
        return jsonify({
            "code": 200,
            "message": "查询健康数据成功",
            "data": mock_week_data
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# 7. 发送客服消息接口（POST）
@app.route("/api/service/message/send", methods=["POST"])
def send_service_message():
    try:
        request_data = request.get_json()
        msg_text = request_data.get("text")

        if not msg_text:
            return jsonify({
                "code": -1,
                "message": "消息内容不能为空",
                "data": None
            })

        # 新增用户消息
        user_msg = {
            "text": msg_text,
            "isUser": True,
            "time": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        mock_service_messages.append(user_msg)

        # 模拟客服自动回复
        reply_msg = {
            "text": "感谢您的咨询，您的问题我们已记录，会尽快为您处理！",
            "isUser": False,
            "time": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        mock_service_messages.append(reply_msg)

        return jsonify({
            "code": 200,
            "message": "消息发送成功",
            "data": {
                "userMsg": user_msg,
                "replyMsg": reply_msg
            }
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# 8. 获取客服消息列表接口（GET）
@app.route("/api/service/messages", methods=["GET"])
def get_service_messages():
    try:
        return jsonify({
            "code": 200,
            "message": "查询消息列表成功",
            "data": mock_service_messages
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

@app.route("/api/dashboard", methods=["GET"])
def get_dashboard_data():
    try:
        return jsonify({
            "code": 200,
            "message": "查询消息列表成功",
            "data": {
                "heart_rate": randint(60, 180),
                "pulse": randint(40, 150),
                "sleep_hours": randint(0, 25),
                "tremor_frequency": randint(0, 5)
            }
        })
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

@app.route("/api/recipes", methods=["GET"])
def get_recipes_data():
    try:
        return jsonify({
            "code": 200,
            "message": "查询消息列表成功",
            "data": [
                {"title": "早餐 🤢", "foods":["隔夜馊稀饭 💩","发霉馒头 🧟‍♂️","生蛆咸菜 🐛"]},
                {"title": "午餐 🤮", "foods":["馊掉的剩菜汤泡饭 🥣","黏糊糊凉拌鼻涕虫 🐌","臭鸡蛋炒苍蝇卵 🥚"]},
                {"title": "晚餐 🤧", "foods":["腐烂烂菜叶炖馊豆腐 🥬","变质五花肉炒蛆虫 🥩","酸臭泔水拌饭 🥄"]},
                {"title": "加餐 🤑", "foods":["发臭的隔夜辣条 🌶️","黏手的过期糖豆 🍬","带霉点的干硬面包 🍞"]}
            ]
})
    except Exception as e:
        return jsonify({
            "code": -999,
            "message": f"服务器内部错误：{str(e)}",
            "data": None
        })

# ---------------------- 启动服务 ----------------------
if __name__ == "__main__":
    # 运行 Flask 服务，host=0.0.0.0 允许局域网内设备访问（包括 Flutter 模拟器）
    app.run(
        host="0.0.0.0",
        port=8888,
        debug=True  # 开发环境开启调试模式，生产环境关闭
    )
