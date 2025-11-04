// ignore: depend_on_referenced_packages
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharePrefsHelper {
  //===========================Get Data From Shared Preference===================

  static Future<String> getString(String key,{String defaultValue = ''}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key) ?? defaultValue;
  }



  static Future<List<String>> getLisOfString(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var getListData = preferences.getStringList(key);

    return getListData!;
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getBool(key);
  }

  static Future<int> getInt(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key) ?? (-1);
  }

///===========================Save Data To Shared Preference===================

  static Future<void> setString(String key, String? value) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.setString(key, value!);
    if (value != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      debugPrint("Warning: Trying to set a null value for key: $key");
    }
  }
/*  static Future setString(String key, value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }*/

/*  static Future<void> setString(String key, String? value) async {
   // SharedPreferences preferences = await SharedPreferences.getInstance();
   // await preferences.setString(key, value!);
    if (value != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      print("Warning: Trying to set a null value for key: $key");
    }
  }*/

  static Future<bool> setListOfString(String key, List<String> value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var setListData = await preferences.setStringList(key, value);

    return setListData;
  }

  static Future setBool(String key, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, value);
  }

  static Future setInt(String key, int value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt(key, value);
  }

//===========================Remove Value===================

  static Future remove(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }

// //===========================Save user===================
// // Save user locally
//   static Future<void> saveUserLocally(String email, String phone) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> emails = prefs.getStringList("emails") ?? [];
//     List<String> phones = prefs.getStringList("phones") ?? [];
//
//     if (!emails.contains(email)) emails.add(email);
//     if (!phones.contains(phone)) phones.add(phone);
//
//     await prefs.setStringList("emails", emails);
//     await prefs.setStringList("phones", phones);
//   }
//
// // Check email exists
//   static Future<bool> isEmailExists(String email) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> emails = prefs.getStringList("emails") ?? [];
//     return emails.contains(email.trim());
//   }
//
// // Check phone exists
//   static Future<bool> isPhoneExists(String phone) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> phones = prefs.getStringList("phones") ?? [];
//     return phones.contains(phone.trim());
//   }

//=========================== Save user locally ===================
  static Future<void> saveUserLocally(String email, String phone) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> emails = prefs.getStringList("emails") ?? [];
    List<String> phones = prefs.getStringList("phones") ?? [];

    if (!emails.contains(email.trim())) {
      emails.add(email.trim());
    }
    if (!phones.contains(phone.trim())) {
      phones.add(phone.trim());
    }

    await prefs.setStringList("emails", emails);
    await prefs.setStringList("phones", phones);

    // 👉 current user হিসেবে set করো
    await prefs.setString("currentUserEmail", email.trim());
    await prefs.setString("currentUserPhone", phone.trim());
  }

  //=========================== Check Email Exists ===================
  static Future<bool> isEmailExists(String email) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emails = prefs.getStringList("emails") ?? [];
    String? currentUserEmail = prefs.getString("currentUserEmail");

    // যদি current user হয় → error না
    if (currentUserEmail != null && currentUserEmail == email.trim()) {
      return false;
    }

    // অন্য কারো হলে error
    return emails.contains(email.trim());
  }

  //=========================== Check Phone Exists ===================
  static Future<bool> isPhoneExists(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> phones = prefs.getStringList("phones") ?? [];
    String? currentUserPhone = prefs.getString("currentUserPhone");

    if (currentUserPhone != null && currentUserPhone == phone.trim()) {
      return false;
    }

    return phones.contains(phone.trim());
  }





  ///========Save String Value =======
  // Save a string value
  static Future<void> saveData(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }

  // Save String value
  static Future<void> saveString(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }
/*  // Get a string value
  static Future<String?> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }*/

}


