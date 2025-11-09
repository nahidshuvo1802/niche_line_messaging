import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ScreenTimeoutController extends GetxController {
  Timer? _timer;
  final Rx<Duration> selectedTimeout = const Duration(seconds: 30).obs;

  void setTimeoutFromString(String value) {
    switch (value) {
      case '30s':
        selectedTimeout.value = const Duration(seconds: 30);
        break;
      case '1m':
        selectedTimeout.value = const Duration(minutes: 1);
        break;
      case '5m':
        selectedTimeout.value = const Duration(minutes: 5);
        break;
      case '15m':
        selectedTimeout.value = const Duration(minutes: 15);
        break;
      case '30m':
        selectedTimeout.value = const Duration(minutes: 30);
        break;
    }
    resetTimer();
  }

  void resetTimer() {
    _timer?.cancel();
    _timer = Timer(selectedTimeout.value, _lockApp);
  }

  void _lockApp() {
    if (Get.currentRoute != '/lockScreen') {
      Get.toNamed('/lockScreen');
    }
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
