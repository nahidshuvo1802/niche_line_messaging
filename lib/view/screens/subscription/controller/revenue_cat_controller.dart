import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatController extends GetxController {
  // Configuration
  final String _apiKey = 'test_nSirKmhSRyaxetqUuJteYifihxO';
  final String _entitlementId = 'NichLine Inc Pro';

  // State
  var isPro = false.obs;
  var isLoading = true.obs;
  var customerInfo = Rxn<CustomerInfo>();

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    isLoading.value = true;
    try {
      // শুধু অ্যান্ড্রয়েড প্ল্যাটফর্ম চেক করছি বা iOS এ সেফ থাকার জন্য লজিক দিচ্ছি
      if (Platform.isAndroid || Platform.isIOS) {
        await Purchases.setLogLevel(LogLevel.debug);

        PurchasesConfiguration configuration;

        if (Platform.isAndroid) {
          // 🔴 খুব গুরুত্বপূর্ণ: এখানে RevenueCat থেকে পাওয়া আপনার 'goog_' দিয়ে শুরু হওয়া কি-টি বসান
          configuration = PurchasesConfiguration(
            "goog_আপনার_অ্যান্ড্রয়েড_কী_এখানে",
          );
        } else if (Platform.isIOS) {
          // আপাতত iOS কনফিগার না করলেও চলবে, অথবা ফাঁকা স্ট্রিং বা null হ্যান্ডেল করতে পারেন
          // পরে যখন অ্যাপ স্টোরে আপলোড করবেন তখন 'appl_' কি বসাবেন
          configuration = PurchasesConfiguration("appl_placeholder_for_later");
        } else {
          return;
        }

        await Purchases.configure(configuration);
        await _checkEntitlement();
      }
    } on PlatformException catch (e) {
      debugPrint("RevenueCat Init Error: ${e.message}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkEntitlement() async {
    try {
      CustomerInfo info = await Purchases.getCustomerInfo();
      customerInfo.value = info;

      if (info.entitlements.all[_entitlementId] != null &&
          info.entitlements.all[_entitlementId]!.isActive) {
        isPro.value = true;
        debugPrint("✅ User is PRO");
      } else {
        isPro.value = false;
        debugPrint("❌ User is NOT Pro");
      }
    } on PlatformException catch (e) {
      debugPrint("Check Entitlement Error: ${e.message}");
    }
  }

  Future<void> showPaywall() async {
    try {
      // Present the Paywall overlay
      // This uses RevenueCat's UI library to show the paywall configured in the dashboard
      await RevenueCatUI.presentPaywallIfNeeded(_entitlementId);
      debugPrint("Paywall presented");

      // After paywall, refresh status
      await _checkEntitlement();
    } on PlatformException catch (e) {
      debugPrint("Paywall Error: ${e.message}");
    }
  }

  Future<void> showCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } on PlatformException catch (e) {
      debugPrint("Customer Center Error: ${e.message}");
    }
  }

  /// Purchase a specific package if you are building a custom UI instead of using the Paywall
  Future<void> purchasePackage(Package package) async {
    try {
      CustomerInfo info =
          (await Purchases.purchasePackage(package)) as CustomerInfo;
      customerInfo.value = info;
      await _checkEntitlement();
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint("Purchase Error: ${e.message}");
        Get.snackbar(
          "Error",
          e.message ?? "Purchase failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  /// Restoration
  Future<void> restorePurchases() async {
    try {
      CustomerInfo info = await Purchases.restorePurchases();
      customerInfo.value = info;
      await _checkEntitlement();
    } on PlatformException catch (e) {
      debugPrint("Restore Error: ${e.message}");
      Get.snackbar(
        "Error",
        "Restore failed: ${e.message}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
