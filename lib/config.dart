class GlobalConfig {
  GlobalConfig._internal();

  static final GlobalConfig _instance = GlobalConfig._internal();

  static GlobalConfig get instance => _instance;

  String appName = "Dart Demo App";

  String appVersion = "1.0.0";

  static double titleSize = 30;
  static double subTitleSize = 24;
  static double normalFontSize = 16;
}
