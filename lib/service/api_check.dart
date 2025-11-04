import 'package:get/get.dart';

import '../core/app_routes/app_routes.dart';

import '../helper/shared_prefe/shared_prefe.dart';
import '../utils/ToastMsg/toast_message.dart';
import '../utils/app_const/app_const.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) async {
    if (response.statusCode == 401) {
      //await SharePrefsHelper.remove(AppConstants.bearerToken);
     // Get.offAllNamed(AppRoutes.loginScreen);
    } else {
      showCustomSnackBar(response.body['error']);
    }
  }
}
