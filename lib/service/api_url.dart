class ApiUrl {
  static String socketUrl({required String id}) =>
      "http://3.23.1.245:5002?userId=$id";
  static const String baseUrl =
      "https://under-lib-offline-hundreds.trycloudflare.com";

  // ... (comments)

  ///========================= Authentication =========================
  static const String userRegister = "/api/v1/users/create_user";
  static const String therapistRegister = "/user/create";
  static const String otpVerify =
      "/api/v1/users/verify-otp"; // Adjust if needed
  static const String emailVerify = "/user/auth/verify-email";
  static const String signIn = "/api/v1/users/login_user"; // Adjust if needed
  static const String signUp = "/api/v1/users/create_user";
  static const String socialAuth = "/api/v1/user/google_auth";
  static const String verifyOtp = "/api/v1/user/user_verification";
  static String sendAgainOtp({required String email}) =>
      "/api/v1/user/resend_verification_otp/$email";
  static const String verifyOtpForget = "/api/v1/user/verification_forgot_user";

  ///============================Profile====================================

  static const String getMyProfile = "/api/v1/auth/myprofile";
  static const String updateMyProfile = "/api/v1/auth/update_my_profile";
  static String updateUserProfile = "/api/v1/auth/update_my_profile";
  static String updateProfile = "/api/v1/auth/update_my_profile";
  static String updateProfileImage = "/api/v1/auth/update_my_profile";
  static String deleteProfile({required String userId}) =>
      "/api/v1/auth/delete_account/$userId";

  ///====================Social Feed =========================================
  static const String getAllSocialFeeds =
      "/api/v1/video/find_by_all_social_feed_video";
  static const String isLikeReact = "/api/v1/react/isLikeReact";
  static const String isDislikeReact = "/api/v1/react/isDisLikeReact";
  static const String isShare = "/api/v1/react/isShare";
  static String getSocialProfilebyId({required String id}) =>
      "/api/v1/video/specific_user_video_feed/$id";

  ///====================Video Upload======================================
  static const String videoUpload = "/api/v1/video/upload_video_files";

  ///===================Audio Get===========================================
  static const String findMyRecordSound =
      "/api/v1/audio/find_my_all_record_sound";
  static const String soundLibrary = "/api/v1/audio/find_by_all_audio";

  ///==================Audio Upload=======================================
  static const String audioupload = "/api/v1/audio/upload_audio_files";

  ///=================Audio Delete=========================================
  static String audiodelete({required id}) =>
      "/api/v1/audio/delete_audio_file/$id";

  //video get (my feed video)==================
  static const String getAllMyVideos =
      "/api/v1/video/find_myl_social_feed_video";
  //=======================Video Delete (my video)======================
  static String deleteVideo({required videoId}) =>
      "/api/v1/video/delete_video_file/$videoId";

  //==========================Terms & Conditions========================================
  static String termsAndConditions = "/api/v1/setting/find_by_terms_conditions";
  //==========================Privacy Policy=========================================
  static String privacyPolicy = "/api/v1/setting/find_by_privacy_policys";

  //==========================About Us============================================
  static String aboutUs = "/api/v1/setting/find_by_about_us";

  static const String forgetPassword = "/api/v1/user/forgot_password";
  static const String mailForgetOtp = "/auth/forget-password/send-otp";
  static const String getCustomerProfile = "/users/me";
  static const String resetPassword = "/api/v1/user/reset_password";
  static const String farmaciesNearby = "/farmacies/nearby";
  static const String getServices = "/services/";
  static const String getCategories = "/categories/";
  static const String postAddToCart = "/carts/add-to-cart";
  static const String getHomeService = "/service-category/retrive/all";
  static const String termsCondition = "/terms-condition/retrive";
  static const String getSliderImage = "/slider/retrive/all";
  static const String getPopularService = "/service/popular/retrive";
  static const String getOffersService = "/service/offered/retrive";
  static const String getPayment = "/booking/retrive/search?query=upcomming";
  static const String postConversation = "/conversation/create";
  static const String getCategoryList = "/speciality/retrive/search";
  static const String getSubscriptionList = "/subscription/retrive/search";
  static const String getPopularTherapist = "/user/retrive/therapists/popular";
  static String getTherapistBySpeciality({
    required String specialityId,
    required int currentPage,
  }) =>
      "/user/retrive/therapists/speciality/$specialityId?page=$currentPage&limit=12";
  static const String postAppointment = "/appointment/create";
  static String getInvoiceByAppointmentId({required String appointmentId}) =>
      "/invoice/retrieve/appointment/$appointmentId";
  static const String postContactUs = "/contact-us/send-email";
  static String getRecommendService({required String cetagoryId}) =>
      "/outlet/retrive/recommended/category/$cetagoryId/search";
  static String getOutletByService({required String cetagoryId}) =>
      "/outlet/retrive/category/$cetagoryId/search";
  static String getSearchServiceOutlet({
    required String userId,
    required String searchText,
  }) => "/outlet/retrive/category/$userId/search?query=$searchText";
  static String getServiceOutlet({required String userId}) =>
      "/outlet/retrive/category/$userId/search";
  static String getUserProfile({required String userId}) =>
      "/user/retrive/$userId";
  static String getTherapistRegister({required String userId}) =>
      "/user/retrive/$userId";

  static String getInvoice({required String userId}) =>
      "/invoice/retrive/user/$userId/search";
  static String getInvoiceByUser({required String userId}) =>
      "/invoice/retrive/$userId";
  static String getPaymentHistory({required String userId}) =>
      "/payment-history/retrive/user/$userId";
  static String getServiceByOutlet({required String outlateId}) =>
      "/service/retrive/for-user/outlet/$outlateId";
  static String getOrderHistory({required String userId}) =>
      "/booking/retrive/user/$userId";
  static String getNotification({required String userId}) =>
      "/notification/retrive/consumer/$userId";
  static String updateTherapistProfile({required String userId}) =>
      "/user/update/$userId";
  static String dismisSingleNotification({required String notificationId}) =>
      '/notification/dismiss/$notificationId';

  static String clearAllNotification({required String userId}) =>
      '/notification/clear/consumer/$userId';
  static String getMessage({required String userId}) =>
      "/message/retrieve/$userId";
  static String delReason({required String appointmentId}) =>
      "/appointment/cancel/after-approval/$appointmentId";
  static String getConversationByUser({required String conversationId}) =>
      "/conversation/retrive/$conversationId";
  static String getSearchInvoce({required String text}) =>
      "/invoice/retrive/user/678f908a41bd1b6dcc108946/search?query=$text";

  static String getProfile({required String userId}) => "/user/retrive/$userId";
  static String deleteUser({required String userId}) => "/user/delete/$userId";
  static String getWallet({required String userId}) =>
      "/wallet/retrive/user/$userId";
  // static String updateProfileImage ({required String userId}) => '/user/update/profile-picture/67b813b7421435769e24e547';

  static String getDrugsCategory({required String categoriesName}) =>
      "/drugs/category/$categoriesName";
  static String getSingleDrugs({required String userId}) => "/drugs/$userId";
  static String getSearchService({required String text}) =>
      "/service/retrive/search?query=$text";
  static String getAppointment({
    required String userId,
    required String role,
    required String status,
  }) =>
      "/appointment/retrive/$userId?role=$role&appointmentStatus=$status&page=1&limit=100";

  //============================= Send Message =======================

  static String sendMessage = '/message/send';

  ///========================= salon api all implementation =========================
  static String salonProfileShow({required String outletId}) =>
      "/outlet/retrive/$outletId";

  ///========================= salon userProfile update implementation =========================
  static String userProfileUpdate({required String outletId}) =>
      "/outlet/update/$outletId";

  ///========================= salon cover photos update implementation =========================
  static String coverPhotosUpdate({required String outletId}) =>
      "/outlet/change/cover/$outletId";

  ///========================= salon scheduleByDay api implementation =========================

  static String scheduleByDay({required String outletId}) =>
      "/schedule/retrive/$outletId";

  ///========================= salon Service manager api implementation =========================
  static String serviceRetriveById({required String outletId}) =>
      "/service/retrive/outlet/$outletId";

  ///========================= salon Service manager api implementation =========================
  static String serviceCreate = "/service/create";

  ///========================= salon userPhotosUpdate  api implementation =========================
  static String userPhotosUpdate({required String outletId}) =>
      "/outlet/change/profile/$outletId";

  ///========================= salon Service Update api implementation =========================

  static String serviceUpdate({required String serviceId}) =>
      "/service/update/$serviceId";

  ///========================= salon upcomming Booking Show api implementation =========================
  static String upcommingBookingShow({
    required String outletId,
    required String date,
  }) => "/booking/upcomming/retrive/outlet/$outletId?date=$date";

  ///========================= earning retrive outlet  api implementation =========================
  static String earningOutlet({required String outletId}) =>
      "/earning/retrive/outlet/$outletId";

  ///========================= earning retrive outlet  api implementation =========================
  static String earningCompleted = "/booking/retrive/search?query=completed";

  ///========================= salon scheduleBy Day create api implementation =========================
  static String createDaySlots = "/schedule/create-or-update";

  // user //  Booking service =====================================

  static const String createBooking = "/booking/create";

  //============================= Wish list ==========================

  static const String addWishList =
      "/wishlist/add-to-wishlist"; // add to wish list
  static String getWishList({required String userId}) =>
      "/wishlist/retrive/user/$userId"; // Get wish list
  static String deleteWishList({required String userId}) => "/wishlist/delete";

  //======================================Change Password===============================================

  static const String changePassword = "/api/v1/user/change_password";

  //============================= Next Appointment ==========================

  static String nextAppointment({required String userId}) =>
      "/booking/upcomming/retrive/user/$userId";
  static String acceptedAppointment({required String appointmentID}) =>
      "/appointment/accept/$appointmentID";

  static String acceptedAllAppointmentbyTherapist({required String userID}) =>
      "/appointment/retrive/$userID?role=therapist&appointmentStatus=approved";
  static String allToadyAppointments({required String userID}) =>
      "/appointment/retrive/todays/approved/$userID";
  //static String getNotification({required String userId}) => "/notification/user/$userId";

  //============================== Reschedule Booking =========================
  static String rescheduleBooking({required String bookingId}) =>
      "/appointment/reschedule/$bookingId";

  //======================================= Messaqge ===============================

  static String getConversationByUserid({required String userID}) =>
      "/conversation/retrive/$userID";
  static String getNessage({required String conversationId}) =>
      "/message/retrive/$conversationId";
  static String createConversation({required String appointmentID}) =>
      '/conversation/retrive/specific/$appointmentID';

  //=============================== Amount Top up ==================== >>

  static const String amountTopUp = '/wallet/initiate-top-up';

  static const String startVideoCall = '/conversation/start-call';

  ///========================= feedback retrive   api implementation =========================
  ///
  static String feedbackReview({required String outletId}) =>
      "/feedback/retrive/therapist/$outletId";
  // "/feedback/retrive/all/outlet/$outletId";

  ///========================= Review create or update =========================
  static const String feedbackCreateOrUpdate = "/feedback/create-or-update";
}
