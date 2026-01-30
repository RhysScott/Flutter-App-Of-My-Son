import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showAwesomeSnackbar(
  BuildContext context, {
  required String title,
  required String message,
  required String type,
}) {
  ContentType contentType = ContentType.success;

  switch (type) {
    case "success":
      contentType = ContentType.success;
      break;
    case "failure":
      contentType = ContentType.failure;
      break;
    case "warning":
      contentType = ContentType.warning;
      break;
    case "help":
      contentType = ContentType.help;
      break;
  }

  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
