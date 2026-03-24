import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/home/controller/add_member_controller.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';

class AddMemberScreen extends StatelessWidget {
  AddMemberScreen({super.key});

  final AddMemberController controller = Get.put(AddMemberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1527),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => AppNav.back(),
          icon: Icon(Icons.arrow_back, color: const Color(0xFF2DD4BF)),
        ),
        title: Text(
          'Add People',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ================== Selected Members Section ==================
          Obx(() {
            if (controller.selectedMembers.isNotEmpty) {
              return SizedBox(
                height: 90.h,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedMembers.length,
                  itemBuilder: (context, index) {
                    final member = controller.selectedMembers[index];
                    final name = member.name ?? "Unknown";
                    final photo = member.photo ?? "";

                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipOval(
                                child: Container(
                                  width: 48.r,
                                  height: 48.r,
                                  color: Colors.grey[800],
                                  child: photo.isNotEmpty
                                      ? Image.network(
                                          ApiUrl.getImageUrl(photo),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Center(
                                                  child: Text(
                                                    name.isNotEmpty
                                                        ? name[0]
                                                        : "?",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                        )
                                      : Center(
                                          child: Text(
                                            name.isNotEmpty ? name[0] : "?",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => controller.toggleMember(member),
                                  child: CircleAvatar(
                                    radius: 10.r,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            name.split(" ")[0],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // ================== Search Bar ==================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.searchRecipients,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white38),
                hintText: 'Search people...',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================== Members List ==================
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                );
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount:
                    controller.filteredRecipients.length +
                    (controller.isMoreLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredRecipients.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final recipient = controller.filteredRecipients[index];
                  return Obx(() {
                    final isSelected = controller.isMemberSelected(recipient);
                    final name = recipient.name ?? "Unknown";
                    final photo = recipient.photo ?? "";

                    return ListTile(
                      onTap: () => controller.toggleMember(recipient),
                      contentPadding: EdgeInsets.zero,
                      leading: ClipOval(
                        child: Container(
                          width: 48.r,
                          height: 48.r,
                          color: Colors.grey[800],
                          child: photo.isNotEmpty
                              ? Image.network(
                                  ApiUrl.getImageUrl(photo),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                    );
                                  },
                                )
                              : Icon(Icons.person, color: Colors.white54),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Container(
                        height: 24.w,
                        width: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF2DD4BF)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2DD4BF)
                                : Colors.white38,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16.sp,
                                color: Colors.black,
                              )
                            : null,
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.isAdding.value) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF2DD4BF),
            onPressed: () {},
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        if (controller.selectedMembers.isEmpty) return SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: controller.addMembers,
          backgroundColor: const Color(0xFF2DD4BF),
          label: Text(
            "Add Member",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          icon: Icon(Icons.check, color: Colors.black),
        );
      }),
    );
  }
}
