import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/profile_controller.dart';
import 'package:niche_line_messaging/view/screens/settings/views/edit_profile_screen.dart';
import 'package:niche_line_messaging/view/components/shimmer/shimmer_loading.dart';

// ==================== Account Screen ====================
class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1527),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Accounts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color.fromARGB(255, 31, 41, 55)],
                tileMode: TileMode.mirror,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const ProfileShimmer();
            }

            final data = controller.profileData.value;
            if (data == null) {
              return Center(
                child: Text(
                  'Failed to load profile',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // ==================== Profile Card ====================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 21, 39),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Image with Edit Button
                        Stack(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 100.r,
                                height: 100.r,
                                color: Colors.grey[700],
                                child:
                                    (data.photo != null &&
                                        data.photo!.isNotEmpty)
                                    ? Image.network(
                                        ApiUrl.getImageUrl(data.photo),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                size: 50.sp,
                                                color: Colors.white,
                                              );
                                            },
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 50.sp,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => EditProfileScreen(initialData: data),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2DD4BF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Name
                        Text(
                          data.name ?? 'Unknown Name',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Email / Bio
                        Text(
                          data.email ?? 'No email provided',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        if (data.location != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            data.location!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF2DD4BF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ==================== Device Info Section ====================
                  _buildDeviceInfoCard(data.model, data.manufacturer),

                  SizedBox(height: 200.h),

                  // ==================== Log Out Button ====================
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () {
                        _showLogoutConfirmation(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(String? model, String? manufacturer) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 14, 21, 39),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DD4BF).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.devices_other,
                  color: const Color(0xFF2DD4BF),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Device Information",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          SizedBox(height: 16.h),
          _buildInfoRow("Model", model ?? "Unknown Device"),
          SizedBox(height: 12.h),
          _buildInfoRow("Manufacturer", manufacturer ?? "Unknown Brand"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white60, fontSize: 14.sp),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==================== Show Logout Confirmation ====================
  void _showLogoutConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to log out from this device?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.find<AuthController>().logoutUser();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
