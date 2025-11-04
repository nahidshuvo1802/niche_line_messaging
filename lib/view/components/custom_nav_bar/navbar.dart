/*
// ignore_for_file: prefer_const_constructors
import 'package:counta_flutter_app/view/components/custom_image/custom_image.dart';
import 'package:counta_flutter_app/view/screens/user_part_screen/view/user_chat_screen/user_inbox_screen.dart.dart';
import 'package:counta_flutter_app/view/screens/user_part_screen/view/user_my_bookings_screen/user_my_bookings_screen.dart';
import 'package:counta_flutter_app/view/screens/user_part_screen/view/user_home_screen/user_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_icons/app_icons.dart';
import '../../screens/user_part_screen/view/user_profile_screen/user_profile_screen/user_profile_screen.dart';

class NavBar extends StatefulWidget {
  final int currentIndex;

  const NavBar({required this.currentIndex, super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  var bottomNavIndex = 0;

  List<String> unselectedIcon = [
    AppIcons.homeU,
    AppIcons.compacU,
    AppIcons.messageU,
    AppIcons.personU,
  ];

  List<String> selectedIcon = [
    AppIcons.homeS,
    AppIcons.compacS,
    AppIcons.messageS,
    AppIcons.personS,
  ];
  */
/* final List<String> userNavText = [
    AppStrings.home,
    AppStrings.schedule,
    AppStrings.calls,
    AppStrings.notification,
    AppStrings.profile
  ];
*//*


  @override
  void initState() {
    bottomNavIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppColors.navbarClr,
        // borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
      ),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 22.h),
      // alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          unselectedIcon.length,
          (index) => InkWell(
              onTap: () => onTap(index),
              child: Column(
                children: [
                  CustomImage(
                    imageSrc: index == bottomNavIndex
                        ? selectedIcon[index]
                        : unselectedIcon[index],
                    height: bottomNavIndex == index ? 38.h : 29.h,
                    width: 30.w,
                    imageColor: index == bottomNavIndex
                        ? AppColors.primary
                        : AppColors.white,
                  ),
                  */
/*Image.asset(
                    index == bottomNavIndex
                        ? selectedIcon[index]
                        : unselectedIcon[index],
                    height: 24.h,
                    width: 24.w,
                    color: index == bottomNavIndex
                        ? AppColors.green
                        : AppColors.primary,
                  ),*//*

                  */
/*CustomText(
                    top: 6,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    text: userNavText[index],
                    color: index == bottomNavIndex
                        ? AppColors.whiteDarkActive
                        : AppColors.whiteDarkActive,
                  ),*//*

                ],
              )),
        ),
      ),
    );
  }

  void onTap(int index) {
    if (index == 0 && widget.currentIndex != 0) {
      Get.offAll(() => UserHomeScreen());
    } else if (index == 1 && widget.currentIndex != 1) {
      Get.offAll(() => UserMyBookingsScreen());
    } else if (index == 2 && widget.currentIndex != 2) {
       Get.offAll(() => UserInboxScreen());
    } else if (index == 3 && widget.currentIndex != 3) {
        Get.offAll(() => UserProfileScreen());
    }
  }
}
*/
