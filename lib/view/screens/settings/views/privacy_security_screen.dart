import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/screen_timeout_controller.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final RxBool isFaceIDEnabled = false.obs;
  final RxBool isReadReceiptsEnabled = true.obs;
  final RxBool isOnlineStatusEnabled = true.obs;
  final RxString screenLockTimeout = '30s'.obs;

  final timeoutController = Get.put(ScreenTimeoutController());

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings from Shared Preferences
  Future<void> _loadSettings() async {
    bool enabled = await SharePrefsHelper.getBool('isBiometricEnabled') ?? false;
    isFaceIDEnabled.value = enabled;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: timeoutController.resetTimer,
      onPanDown: (_) => timeoutController.resetTimer(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E1527),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Privacy & Security',
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
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),

                  // ==================== Authentication Section ====================
                  _buildSectionCard(
                    title: 'Authentication & Lock',
                    children: [
                      Obx(() => _buildSwitchOption(
                        icon: Icons.fingerprint,
                        title: 'Face ID / Fingerprint',
                        subtitle: 'Use biometrics to unlock',
                        value: isFaceIDEnabled.value,
                        onChanged: (v) async {
                          isFaceIDEnabled.value = v;
                          // Save setting to preferences
                          await SharePrefsHelper.setBool('isBiometricEnabled', v);

                          Get.snackbar(
                            'Success',
                            v ? 'Biometric enabled' : 'Biometric disabled',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 1),
                          );
                        },
                      )),
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      _buildNavigationOption(
                        icon: Icons.timer_outlined,
                        title: 'Screen Lock Timeout',
                        subtitle: 'Automatically locks after inactivity',
                        trailing: Obx(() => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              screenLockTimeout.value,
                              style: TextStyle(
                                  color: const Color(0xFF2DD4BF),
                                  fontSize: 14.sp),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.chevron_right,
                                color: Colors.white.withOpacity(0.3),
                                size: 20.sp),
                          ],
                        )),
                        onTap: () => _showTimeoutOptions(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ==================== Messaging Privacy Section ====================
                  _buildSectionCard(
                    title: 'Messaging Privacy',
                    children: [
                      // Read Receipts
                      Obx(() => _buildSwitchOption(
                        icon: Icons.done_all,
                        title: 'Read Receipts',
                        subtitle: 'Allow others to see when you\'ve read their messages',
                        value: isReadReceiptsEnabled.value,
                        onChanged: (value) {
                          isReadReceiptsEnabled.value = value;
                        },
                      )),

                      Divider(color: Colors.white.withOpacity(0.1), height: 1),

                      // Online Status
                      Obx(() => _buildSwitchOption(
                        icon: Icons.circle,
                        title: 'Online Status',
                        subtitle: 'Show when you\'re active',
                        value: isOnlineStatusEnabled.value,
                        onChanged: (value) {
                          isOnlineStatusEnabled.value = value;
                        },
                      )),

                      Divider(color: Colors.white.withOpacity(0.1), height: 1),

                      // Blocked Contacts
                      _buildNavigationOption(
                        icon: Icons.block,
                        title: 'Blocked Contacts',
                        subtitle: 'View and manage blocked users',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // ==================== Backup & Recovery Section ====================
                  _buildSectionCard(
                    title: 'Backup & Recovery',
                    subtitle: 'Securely store your message keys with a passphrase.',
                    children: [
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () => _showBackupDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2DD4BF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Manage Backups',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Last backup: Aug 23, 2025, 10:45 AM',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // ==================== Danger Zone Section ====================
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: const Color(0x0E1521),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Danger Zone',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'These actions cannot be undone.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Delete All Messages',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Widget Helpers ====================

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 14, 21, 39),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
          if (children.isNotEmpty) SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2DD4BF), size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2DD4BF),
            activeTrackColor: const Color(0xFF2DD4BF).withOpacity(0.5),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2DD4BF), size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                  size: 20.sp,
                ),
          ],
        ),
      ),
    );
  }

  void _showTimeoutOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Screen Lock Timeout',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            _buildTimeoutOption('30s'),
            _buildTimeoutOption('1m'),
            _buildTimeoutOption('5m'),
            _buildTimeoutOption('15m'),
            _buildTimeoutOption('30m'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeoutOption(String time) {
    return Obx(() => ListTile(
      title: Text(
        time,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: screenLockTimeout.value == time
          ? const Icon(Icons.check, color: Color(0xFF2DD4BF))
          : null,
      onTap: () {
        screenLockTimeout.value = time;
        Get.back();
      },
    ));
  }

  void _showBackupDialog() {}

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Delete All Messages?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will permanently delete all your messages.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'All messages deleted', backgroundColor: Colors.green, colorText: Colors.white);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}