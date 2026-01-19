import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/utils/ToastMsg/toast_message.dart';
import 'package:niche_line_messaging/view/screens/subscription/model/subscription_model.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/auth_screen/auth_screen.dart';

class SubscriptionController extends GetxController {
  // ==================== Reactive State ====================
  final RxBool isPurchasing = false.obs;
  final RxBool isLoadingSubscription = false.obs;
  final RxBool isLoadingAllSubscription = false.obs;

  final Rx<SubscriptionModel?> allSubscriptionData = Rx<SubscriptionModel?>(
    null,
  );

  // Active Subscription Data
  final RxString activePlanType = ''.obs;
  final RxInt remainingDays = 0.obs;
  final RxInt activeDays = 0.obs; // To show how many days have passed
  final RxString expiryDate = ''.obs;
  final RxBool hasActiveSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    getActiveSubscription();
    getAllSubscriptions();
  }

  /// =====================================================
  /// 🟢 RECORD SUBSCRIPTION (Start Free Trial)
  /// =====================================================
  Future<void> purchaseSubscription() async {
    isPurchasing.value = true;

    try {
      // Hardcoded ID as per requirement for Free Plan
      Map<String, dynamic> body = {
        "subscriptionId": "69360972fc2c85112647d63d",
        "typesubscription": "free",
      };

      debugPrint("🚀 Recording Subscription: $body");

      Response response = await ApiClient.postData(
        ApiUrl.recordedSubscription,
        body,
      );

      _handleSubscriptionResponse(response);
    } catch (e) {
      debugPrint("Subscription Error: $e");
      showCustomSnackBar("Something went wrong: $e", isError: true);
    } finally {
      isPurchasing.value = false;
    }
  }

  /// =====================================================
  /// 💰 PURCHASE PAID SUBSCRIPTION
  /// =====================================================
  Future<void> purchasePaidSubscription({
    required String subscriptionId,
    required String priceId,
  }) async {
    isPurchasing.value = true;

    try {
      Map<String, dynamic> body = {
        "subscriptionId": subscriptionId,
        "subscriptionPriceId": priceId,
        "typesubscription": "paid",
      };

      debugPrint("🚀 Recording Paid Subscription: $body");

      Response response = await ApiClient.postData(
        ApiUrl.recordedSubscription,
        body,
      );

      _handleSubscriptionResponse(response);
    } catch (e) {
      debugPrint("Paid Subscription Error: $e");
      showCustomSnackBar("Something went wrong: $e", isError: true);
    } finally {
      isPurchasing.value = false;
    }
  }

  void _handleSubscriptionResponse(Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successful or Already Exists
      Map<String, dynamic> responseData = response.body;

      // Check nested response structure
      String message = "Subscription Successful";

      if (responseData['message'] != null) {
        message = responseData['message'];
      }

      // Handle nested data message like "You already have free subscription"
      if (responseData['data'] != null &&
          responseData['data'] is Map &&
          responseData['data']['message'] != null) {
        message = responseData['data']['message'];
      }

      showCustomSnackBar(message, isError: false);

      // Refresh active subscription data
      await getActiveSubscription();

      // Navigate to Auth Screen (Login)
      Get.offAll(() => const AuthScreen());
    } else {
      String errorMessage =
          response.statusText ?? "Failed to record subscription";
      if (response.body != null && response.body['message'] != null) {
        errorMessage = response.body['message'];
      }
      showCustomSnackBar(errorMessage, isError: true);
    }
  }

  /// =====================================================
  /// 🌍 GET ALL SUBSCRIPTION PLANS
  /// =====================================================
  Future<void> getAllSubscriptions() async {
    isLoadingAllSubscription.value = true;
    try {
      Response response = await ApiClient.getData(ApiUrl.allSubscription);

      if (response.statusCode == 200 || response.statusCode == 201) {
        allSubscriptionData.value = SubscriptionModel.fromJson(response.body);
        debugPrint(
          "✅ All Subscriptions Loaded: ${allSubscriptionData.value?.data?.allSubscriptionList?.length} items",
        );
      } else {
        debugPrint("❌ Failed to load subscriptions: ${response.statusText}");
      }
    } catch (e) {
      debugPrint("❌ Error loading subscriptions: $e");
    } finally {
      isLoadingAllSubscription.value = false;
    }
  }

  /// =====================================================
  /// 🔍 GET ACTIVE SUBSCRIPTION & CALCULATE REMAINING DAYS
  /// =====================================================
  Future<void> getActiveSubscription() async {
    isLoadingSubscription.value = true;

    try {
      Response response = await ApiClient.getData(
        ApiUrl.findMyActiveSubscription,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API response format: { data: [ { ... } ] }
        List<dynamic> data = response.body['data'] ?? [];

        if (data.isNotEmpty) {
          var subscription = data.first; // Taking the first active one

          bool isActive = subscription['isActive'] ?? false;
          String type = subscription['typesubscription'] ?? 'unknown';
          String createdAtStr = subscription['createdAt'];

          if (isActive && type == 'free') {
            hasActiveSubscription.value = true;
            activePlanType.value = type;

            // Calculate Remaining Days
            DateTime createdAt = DateTime.parse(createdAtStr);
            DateTime now = DateTime.now();
            DateTime expiry = createdAt.add(
              const Duration(days: 60),
            ); // 60 Days Trial

            Duration activeDuration = now.difference(createdAt);
            Duration difference = expiry.difference(now);

            // Active Days
            if (activeDuration.isNegative) {
              activeDays.value = 0;
            } else {
              activeDays.value = activeDuration.inDays;
            }

            if (difference.isNegative) {
              remainingDays.value = 0;
            } else {
              remainingDays.value = difference.inDays;
            }

            expiryDate.value = expiry.toString().split(' ')[0]; // YYYY-MM-DD

            debugPrint(
              "✅ Active Free Subscription Found: ${remainingDays.value} days remaining.",
            );
          }
        } else {
          hasActiveSubscription.value = false;
          remainingDays.value = 0;
        }
      } else {
        debugPrint("Failed to fetch subscription: ${response.statusText}");
      }
    } catch (e) {
      debugPrint("Get Subscription Error: $e");
    } finally {
      isLoadingSubscription.value = false;
    }
  }
}
