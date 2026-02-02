from flask import Flask

# 初始化 Flask 应用
app = Flask(__name__)

# 定义一个简单的 HTTP 接口
@app.route('/')
def index():
    return {
        "msg": "Hello IPv6 HTTP Server!",
        "status": "success",
        "your_ipv6": "2409:8962:2ba4:f6db:8ec:fd0f:7229:37ee"
    }

if __name__ == "__main__":
    print(f"✅ IPv6 HTTP 服务器已启动（Flask）")
    print(f"   公网访问链接：http://[2409:8962:2ba4:f6db:8ec:fd0f:7229:37ee]:8080")
    app.run(host='::', port=80, debug=True)
