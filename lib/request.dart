import 'dart:convert';

import 'package:aaa/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

class HttpUtil {
  final Logger _logger = Logger('HttpUtil');
  late final Dio _dio;
  String? savedPhone;
  String? savedPassword;

  HttpUtil() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://noahmiller.icu:8080/api", // 这里可以根据需要调整 URL
        // baseUrl: "http://localhost:8080/api", // 这里可以根据需要调整 URL
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": "application/json;charset=utf-8",
          "Accept": "application/json",
        },
        // 关键：让 400~499 也能拿到 response body，而不是直接抛异常
        validateStatus: (status) => status != null && status < 500,
        responseType: ResponseType.json,
      ),
    );

    // 拦截器：强制打印所有细节
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
            '╔══════════════════════════════════════ REQUEST START ══════════════════════════════════════',
          );
          print('║ URL: ${options.uri}');
          print('║ Method: ${options.method}');
          print('║ Token: ${options.headers['Authorization'] ?? '无 token'}');
          print('║ All Headers: ${options.headers}');
          if (options.data != null) {
            try {
              print('║ Body: ${jsonEncode(options.data)}');
            } catch (_) {
              print('║ Body (raw): $options.data');
            }
          }
          if (options.queryParameters.isNotEmpty) {
            print('║ Query Params: ${options.queryParameters}');
          }
          print(
            '╚══════════════════════════════════════ REQUEST END ════════════════════════════════════════',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '╔══════════════════════════════════════ RESPONSE SUCCESS ══════════════════════════════════════',
          );
          print('║ Status: ${response.statusCode} ${response.statusMessage}');
          print('║ Real URL: ${response.realUri}');
          try {
            print('║ Response Body: ${jsonEncode(response.data)}');
          } catch (_) {
            print('║ Response Body (raw): ${response.data}');
          }
          print(
            '╚══════════════════════════════════════ RESPONSE END ════════════════════════════════════════',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            '╔══════════════════════════════════════ !!! ERROR !!! ══════════════════════════════════════',
          );
          print('║ URL: ${e.requestOptions.uri}');
          print('║ Type: ${e.type}');
          print('║ Message: ${e.message}');
          print(
            '║ Token sent: ${e.requestOptions.headers['Authorization'] ?? '无'}',
          );

          if (e.response != null) {
            print('║ Status: ${e.response?.statusCode}');
            print('║ Status Message: ${e.response?.statusMessage}');
            try {
              print('║ Error Response Body: ${jsonEncode(e.response?.data)}');
            } catch (_) {
              print('║ Error Response Body (raw): ${e.response?.data}');
            }
            print('║ Headers received: ${e.response?.headers}');
          } else {
            print('║ No response received (可能是网络断开/超时/取消)');
          }

          print('║ Stack: ${e.stackTrace}');
          print(
            '╚══════════════════════════════════════ ERROR END ════════════════════════════════════════',
          );
          return handler.next(e);
        },
      ),
    );
  }

  void saveUserInfo(String phone, String password) {
    savedPhone = phone;
    savedPassword = password;
  }

  void clearUserInfo() {
    savedPhone = null;
    savedPassword = null;
  }

  Future<Map<String, dynamic>?> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final uid = await LocalStorage.get('_user_id');
    try {
      final response = await _dio.get(
        path + "?user_id=$uid",
        queryParameters: params,
      );
      return _parseAndReturn(response);
    } on DioException catch (e) {
      return _handleAndReturnError(e);
    } catch (e, s) {
      print('【未知异常】 $e\n$s');
      return {"code": -999, "message": "未知异常: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>?> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final uid = await LocalStorage.get('_user_id');

    try {
      final response = await _dio.post(path + "?user_id=$uid", data: data);
      return _parseAndReturn(response);
    } on DioException catch (e) {
      return _handleAndReturnError(e);
    } catch (e, s) {
      print('【未知异常】 $e\n$s');
      return {"code": -999, "message": "未知异常: $e", "data": null};
    }
  }

  Map<String, dynamic> _parseAndReturn(Response response) {
    dynamic raw = response.data;
    Map<String, dynamic> result = {};

    if (raw is Map<String, dynamic>) {
      result = raw;
    } else if (raw is String) {
      try {
        result = json.decode(raw);
      } catch (_) {
        result = {"raw_string": raw};
      }
    } else {
      result = {"raw": raw.toString()};
    }

    return {
      "code": result["code"] ?? (response.statusCode == 200 ? 0 : -1),
      "message": result["message"] ?? "操作成功",
      "data": result["data"] ?? result,
    };
  }

  Map<String, dynamic> _handleAndReturnError(DioException e) {
    String msg = "网络错误";
    dynamic detail;

    if (e.response?.data != null) {
      try {
        final errBody = jsonEncode(e.response!.data);
        print('【后端返回的完整错误体】 $errBody');
        detail = e.response!.data;
        if (e.response!.statusCode == 422) {
          msg = "参数验证失败 (422)";
          if (detail is Map && detail['detail'] != null) {
            msg += " → ${jsonEncode(detail['detail'])}";
          }
        } else if (e.response!.statusCode == 401) {
          msg = "登录失效，请重新登录 (401)";
        }
      } catch (_) {
        msg = "服务器返回格式异常";
      }
    }

    return {"code": -1, "message": msg, "data": null, "errorDetail": detail};
  }
}
