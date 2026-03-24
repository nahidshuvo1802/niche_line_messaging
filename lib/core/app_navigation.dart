import 'package:get/get.dart';

/// GetX [Get.back] returns after only dismissing a snackbar when
/// [Get.isSnackbarOpen] is true, so the route does not pop on the first tap.
/// This clears snackbars first, then pops the root navigator route.
class AppNav {
  AppNav._();

  static void back<T>({T? result}) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    final nav = Get.key.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop<T>(result);
    }
  }
}
