import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';

/// Service to manage subscription-related operations
class SubscriptionService {
  static const String _subscriptionIdKey = 'current_subscription_id';

  /// Fetch active subscription from API and save ID to local storage
  /// API: /api/v1/current_subscription/find_my_active_current_subscription
  /// Response: { data: [{ _id: "subscription_id", isActive: true, ... }] }
  static Future<String?> fetchAndSaveActiveSubscription() async {
    try {
      debugPrint(
        '📡 Calling subscription API: ${ApiUrl.getMyActiveSubscription}',
      );
      var response = await ApiClient.getData(ApiUrl.getMyActiveSubscription);

      debugPrint('📡 Subscription API Response: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var body = response.body;

        if (body != null && body['success'] == true && body['data'] != null) {
          var dataList = body['data'];

          // data is an array, get first element
          if (dataList is List && dataList.isNotEmpty) {
            var firstSubscription = dataList[0];
            String? subscriptionId = firstSubscription['_id'];

            if (subscriptionId != null && subscriptionId.isNotEmpty) {
              // Save to local storage
              await saveSubscriptionId(subscriptionId);
              debugPrint('✅ Subscription ID saved: $subscriptionId');
              return subscriptionId;
            }
          }
        }
      } else {
        debugPrint('❌ Failed to fetch subscription: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching subscription: $e');
    }
    return null;
  }

  /// Save subscription ID to local storage
  static Future<void> saveSubscriptionId(String subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionIdKey, subscriptionId);
  }

  /// Get saved subscription ID from local storage
  static Future<String?> getSubscriptionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subscriptionIdKey);
  }

  /// Clear subscription ID from local storage
  static Future<void> clearSubscriptionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_subscriptionIdKey);
  }

  /// Check if user has an active subscription saved
  static Future<bool> hasActiveSubscription() async {
    final subscriptionId = await getSubscriptionId();
    return subscriptionId != null && subscriptionId.isNotEmpty;
  }
}
