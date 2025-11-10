import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/theme_controller.dart';
import 'package:niche_line_messaging/view/screens/settings/views/apperance_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/app_routes/app_routes.dart';
import 'utils/app_colors/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   Get.put(ThemeController(), permanent: true);
  await Permission.microphone.request();
  await Permission.storage.request();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(393, 852),
      child: Obx(
        () => GetMaterialApp(
          title: "NicheLine",
          theme: AppTheme.lightTheme(themeController.fontSize.value),
          darkTheme: AppTheme.darkTheme(themeController.fontSize.value),
          themeMode: themeController.themeMode.value == 'light'
              ? ThemeMode.light
              : themeController.themeMode.value == 'dark'
                  ? ThemeMode.dark
                  : ThemeMode.system,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          initialRoute: AppRoutes.splashScreen,
          getPages: AppRoutes.routes,
        ),
      ),
    );
  }
}
