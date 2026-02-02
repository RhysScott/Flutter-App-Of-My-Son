
# %%
# curl -X POST http://localhost:8080/api/user/login \
#     -H "Content-Type: application/json" \
#     -d '{"phone":"18180561419", "password":"kissme"}' | jq 

# # %%
# curl -X POST http://localhost:8080/api/user/register \
#     -H "Content-Type: application/json" \
#     -d '{"phone":"18180561419", "password":"kissme"}' | jq 

# %%
# curl "http://localhost:8080/api/user/profile?user_id=2" | jq

# %%
# curl -X POST http://localhost:8080/api/user/profile?user_id=2 \
#     -H "Content-Type: application/json" \
#     -d '  {"code": 200,
#   "data": {
#     "age": 0,
#     "currentAddress": "",
#     "emergencyName": "",
#     "emergencyPhone": "",
#     "gender": "未知",
#     "name": "新用户",
#     "tag": "无",
#     "uid": 2
#   },
# }'


curl http://localhost:8080/api/user/profile?user_id=2
