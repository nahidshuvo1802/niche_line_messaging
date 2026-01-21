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
      if (Platform.isAndroid || Platform.isIOS) {
        await Purchases.setLogLevel(LogLevel.debug);

        PurchasesConfiguration configuration;
        if (Platform.isAndroid) {
          configuration = PurchasesConfiguration(_apiKey);
        } else if (Platform.isIOS) {
          configuration = PurchasesConfiguration(_apiKey);
        } else {
          // Fallback or handle web/desktop if needed
          debugPrint(
            "RevenueCat only supports Android/iOS via official SDK usually. Skipping init.",
          );
          isLoading.value = false;
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
