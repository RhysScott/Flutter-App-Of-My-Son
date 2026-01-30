import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

class HttpUtil {
  final Logger _logger = Logger('HttpUtil');
  final Dio _dio = Dio();
  String? savedPhone;
  String? savedPassword;

  // 初始化Dio配置
  HttpUtil() {
    _dio.options = BaseOptions(
      // baseUrl: "http://localhost:8888/api",
      baseUrl: "http://noahmiller.icu:8080/api",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json;charset=utf-8",
        "Accept": "application/json",
      },
      responseType: ResponseType.json,
    );
  }

  // 存储账号密码
  void saveUserInfo(String phone, String password) {
    savedPhone = phone;
    savedPassword = password;
  }

  // 清空账号密码
  void clearUserInfo() {
    savedPhone = null;
    savedPassword = null;
  }

  // GET请求
  Future<Map<String, dynamic>?> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: params);

      final Map<String, dynamic> result = response.data is Map
          ? response.data as Map<String, dynamic>
          : json.decode(response.data.toString()) as Map<String, dynamic>;

      return {
        "code": result["code"] ?? -1,
        "message": result["message"] ?? "请求成功",
        "data": result["data"],
      };
    } on DioException catch (e) {
      _logDioError(e);
      return _handleDioError(e);
    } catch (e) {
      _logUnknownError(e);
      return {"code": -999, "message": "未知异常，请稍后重试", "data": null};
    }
  }

  // POST请求
  Future<Map<String, dynamic>?> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);

      final Map<String, dynamic> result = response.data is Map
          ? response.data as Map<String, dynamic>
          : json.decode(response.data.toString()) as Map<String, dynamic>;

      return {
        "code": result["code"] ?? -1,
        "message": result["message"] ?? "请求成功",
        "data": result["data"],
      };
    } on DioException catch (e) {
      _logDioError(e);
      return _handleDioError(e);
    } catch (e) {
      _logUnknownError(e);
      return {"code": -999, "message": "未知异常，请稍后重试", "data": null};
    }
  }

  // 处理Dio错误
  Map<String, dynamic> _handleDioError(DioException e) {
    String message = "网络异常，请检查网络";

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = "网络连接超时，请稍后重试";
        break;
      case DioExceptionType.receiveTimeout:
        message = "数据接收超时，请稍后重试";
        break;
      case DioExceptionType.badResponse:
        message = "接口返回错误（${e.response?.statusCode}）";
        break;
      case DioExceptionType.cancel:
        message = "请求已取消";
        break;
      case DioExceptionType.unknown:
        message = "网络未连接，请检查网络设置";
        break;
      default:
        message = "未知错误，请稍后重试";
        break;
    }

    return {"code": -1, "message": message, "data": null};
  }

  // 打印Dio错误日志
  void _logDioError(DioException e) {
    _logger.severe(
      "URL: ${e.requestOptions.baseUrl}${e.requestOptions.path} | Message: ${e.message}",
    );
  }

  // 打印未知错误日志
  void _logUnknownError(Object e) {
    _logger.severe("Unknown Error: $e");
  }
}
