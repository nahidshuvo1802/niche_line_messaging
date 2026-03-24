import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:niche_line_messaging/core/app_routes/app_routes.dart';
import 'package:niche_line_messaging/view/screens/subscription/controller/subscription_controller.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';

class SubscriptionUpgradeScreen extends StatelessWidget {
  const SubscriptionUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingAllSubscription.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final subscriptionList =
              controller.allSubscriptionData.value?.data?.allSubscriptionList;
          final subscriptionItem =
              (subscriptionList != null && subscriptionList.isNotEmpty)
              ? subscriptionList.first
              : null;

          if (subscriptionItem == null) {
            return Center(
              child: Text(
                "No subscription plans available",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                SizedBox(height: 16.h),

                Icon(Icons.shield, color: AppColors.loading, size: 42.sp),

                SizedBox(height: 10.h),

                Text(
                  subscriptionItem.title ?? "Unlock Even More with NichLine",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 10.h),

                Text(
                  subscriptionItem.description ??
                      "You've been loving NichLine! Upgrade to our Best Value or Commit & Save Big options and get 15-30% off your subscription.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 28.h),

                if (subscriptionItem.subscriptionType30 != null)
                  _featureCard(
                    title:
                        subscriptionItem.subscriptionType30!.title ??
                        "Best Value",
                    saveTextColor: Colors.greenAccent,
                    saveLabel: "Save 30%",
                    features:
                        subscriptionItem.subscriptionType30!.features ?? [],
                  ),

                SizedBox(height: 18.h),

                if (subscriptionItem.subscriptionType15 != null)
                  _featureCard(
                    title:
                        subscriptionItem.subscriptionType15!.title ??
                        "Best Value",
                    saveTextColor: Colors.orangeAccent,
                    saveLabel: "Save 15%",
                    features:
                        subscriptionItem.subscriptionType15!.features ?? [],
                  ),

                SizedBox(height: 28.h),

                // Dynamic Buttons
                if (subscriptionItem.subscriptionPrice != null)
                  ...subscriptionItem.subscriptionPrice!.asMap().entries.map((
                    entry,
                  ) {
                    final price = entry.value;
                    final index = entry.key;

                    // Style the first button as primary (ElevatedButton) and others as secondary (OutlinedButton)
                    // Or style based on content. For now, alternating or check index.
                    // Let's simply make the first one primary, second secondary as per original UI.

                    if (index == 0) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (subscriptionItem.sId != null &&
                                    price.sId != null) {
                                  _showPurchaseDialog(
                                    context,
                                    controller,
                                    subscriptionId: subscriptionItem.sId!,
                                    priceId: price.sId!,
                                    priceLabel: price.pricetype ?? "",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                "${price.pricetype} →",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                if (subscriptionItem.sId != null &&
                                    price.sId != null) {
                                  _showPurchaseDialog(
                                    context,
                                    controller,
                                    subscriptionId: subscriptionItem.sId!,
                                    priceId: price.sId!,
                                    priceLabel: price.pricetype ?? "",
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFF2DD4BF),
                                  width: 1.3,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                "${price.pricetype} →",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2DD4BF),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      );
                    }
                  }),

                TextButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.homeScreen);
                  },
                  child: Text(
                    "Maybe later",
                    style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  "🔒 256-bit encryption     🛡️ Zero logs",
                  style: TextStyle(fontSize: 13.sp, color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required String saveLabel,
    required Color saveTextColor,
    required List<String> features,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.primary,
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: saveTextColor.withOpacity(.15),
                ),
                child: Text(
                  saveLabel,
                  style: TextStyle(
                    color: saveTextColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...features.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16.sp,
                    color: const Color(0xFF2DD4BF),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    f,
                    style: TextStyle(color: Colors.white70, fontSize: 13.5.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    SubscriptionController controller, {
    required String subscriptionId,
    required String priceId,
    required String priceLabel,
  }) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Purchase",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: const Color(0xFF0E1527),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: const Color(0xFF2DD4BF), width: 1),
            ),
            title: Icon(
              Icons.workspace_premium,
              color: const Color(0xFF2DD4BF),
              size: 48.sp,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Confirm Purchase",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  "Are you sure you want to buy the subscription?",
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    priceLabel,
                    style: TextStyle(
                      color: const Color(0xFF2DD4BF),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => AppNav.back(),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white54, fontSize: 16.sp),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  AppNav.back(); // Close dialog
                  controller.purchasePaidSubscription(
                    subscriptionId: subscriptionId,
                    priceId: priceId,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  "Make Payment",
                  style: TextStyle(
                    color: const Color(0xFF0E1527),
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
