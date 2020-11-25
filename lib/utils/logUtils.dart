import 'package:flutter/cupertino.dart';

class LogUtils {
  static void log(String methodName, String message) {
    debugPrint("{$methodName} {$message}");
  }
}
