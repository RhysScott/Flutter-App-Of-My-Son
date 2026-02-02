import 'package:flutter/material.dart';

// 全局 ScaffoldMessengerKey
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

// 原生 Snackbar 方法
void showSnack(
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  messengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: duration));
}
