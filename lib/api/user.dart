import 'package:aaa/utils/storage.dart';
import 'package:flutter/cupertino.dart';

import '../request.dart';

Future<Map<String, dynamic>> login(String phone, String password) async {
  var res = await HttpUtil().post(
    "/user/login",
    data: {"phone": phone, "password": password},
  );
  Map<String, dynamic>? data = res?["data"];
  debugPrint("$res");

  int? code = res?["code"] as int?;

  if (code == null || code != 200) {
    return {"code": res?["code"] ?? 400, "msg": res?["msg"] ?? "登录失败"};
  }

  LocalStorage.set("_user_id", data?["user"]?["user_id"].toString() ?? "");
  return {"code": 200, "msg": res?["message"] ?? "登录成功"};
}

Future<Map<String, dynamic>> register(String phone, String password) async {
  var res = await HttpUtil().post(
    "/user/register",
    data: {"phone": phone, "password": password},
  );

  debugPrint("$res");

  int? code = res?["code"] as int?;

  if (code == null || code != 200) {
    return {"code": res?["code"] ?? 400, "msg": res?["message"] ?? "注册失败"};
  }

  return {"code": 200, "msg": res?["msg"] ?? "注册成功"};
}
