FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

# app:app：前一个 app 是应用模块名（app.py），后一个 app 是 Flask 应用实例名
CMD ["python3", "app.py"]
