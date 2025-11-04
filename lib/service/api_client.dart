/* import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../helper/shared_prefe/shared_prefe.dart';
import '../utils/app_const/app_const.dart';
import 'api_url.dart';
import 'package:mime/mime.dart';

class ApiClient extends GetxService {
  static var client = http.Client();

  static const String somethingWentWrong = "Something Went Wrong";
  static const int timeoutInSeconds = 30;

  static String bearerToken =
      "zI0NTAwODI4fQ.dTr7dcjgfk9ChQ2oZQ39MGZBQSntiT8YjvZTZowUXas";

//get post put delete


//========================= Get Data =========================
  static Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      //'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',

      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');

      http.Response response = await client
          .get(
            Uri.parse(ApiUrl.baseUrl + uri),
            headers: headers ?? mainHeaders,
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('------------${e.toString()}');
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }


  static Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool isContentType = true}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = isContentType
        ? {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $bearerToken'
          }
        : {
            'Accept': 'application/json',
            'Authorization': 'Bearer $bearerToken'
          };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await client
          .post(
            Uri.parse(ApiUrl.baseUrl + uri),
            body: body,
            headers: headers ?? mainHeaders,
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e, s) {
      debugPrint('Error------------${e.toString()}');
      debugPrint('S------------${s.toString()}');

      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  static Future<Response> patchData(String uri, dynamic body,
      {Map<String, String>? headers, bool isContentType = true}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = isContentType
        ? {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    }
        : {
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await client
          .patch(
        Uri.parse(ApiUrl.baseUrl + uri),
        body: body,
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('------------${e.toString()}');

      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  static Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await http
          .put(
            Uri.parse(ApiUrl.baseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? mainHeaders,
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  ///========================= Review create or update =========================
  /// patient, therapist, rating, comment

static Future<Response> submitFeedback({
  required String patientId,
  required String therapistId,
  required double rating,
  required String comment,
}) async {
  final body = jsonEncode({
    "patient": patientId,
    "therapist": therapistId,
    "rating": rating,
    "comment": comment,
  });

  return await postData(
    ApiUrl.feedbackCreateOrUpdate,
    body,
  );
}


  static Future<Response> postMultipartData(String uri, dynamic body,
      {List<MultipartBody>? multipartBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $bearerToken'
      };

      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');

      var request =
      http.MultipartRequest('POST', Uri.parse(ApiUrl.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");

          var mimeType = lookupMimeType(element.file.path);

          debugPrint("MimeType================$mimeType");

          var multipartImg = await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: MediaType.parse(mimeType!),
          );
          request.files.add(multipartImg);
        });
      }

      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: somethingWentWrong,
          body: content);
    } catch (e) {
      debugPrint('------------${e.toString()}');

      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }




  static Future<Response> putMultipartData(String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
      List<MultipartListBody>? multipartListBody,
      Map<String, String>? headers}) async {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $bearerToken'
      };

      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');

      //http.MultipartRequest _request = http.MultipartRequest('POST', Uri.parse("https://b936-114-130-157-130.ngrok-free.app/api/v1/user/profile/store/degree"));
      //_request.headers.addAll(headers ?? mainHeaders);
      // for(MultipartBody multipart in multipartBody!) {
      //   if(multipart.file != null) {
      //     Uint8List _list = await multipart.file.readAsBytes();
      //     _request.files.add(http.MultipartFile(
      //       multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
      //       filename: '${DateTime.now().toString()}.png',
      //     ));
      //   }
      // }

      var request =
          http.MultipartRequest('PUT', Uri.parse(ApiUrl.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");

          if (element.file.path.contains(".mp4")) {
            debugPrint("media type mp4 ==== ${element.file.path}");
            request.files.add(http.MultipartFile(
              element.key,
              element.file.readAsBytes().asStream(),
              element.file.lengthSync(),
              filename: 'video.mp4',
              contentType: MediaType('video', 'mp4'),
            ));
          } else if (element.file.path.contains(".png")) {
            debugPrint("media type png ==== ${element.file.path}");
            request.files.add(http.MultipartFile(
              element.key,
              element.file.readAsBytes().asStream(),
              element.file.lengthSync(),
              filename: 'image.png',
              contentType: MediaType('image', 'png'),
            ));
          }

          //request.files.add(await http.MultipartFile.fromPath(element.key, element.file.path,contentType: MediaType('video', 'mp4')));
        });
      }

      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: somethingWentWrong,
          body: content);
    } catch (e) {
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  static Future<Response> deleteData(String uri,
      {Map<String, String>? headers, dynamic body}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Call: $uri\n Body: $body');

      http.Response response = await http
          .delete(Uri.parse(ApiUrl.baseUrl + uri),
              headers: headers ?? mainHeaders, body: body)
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  static Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      debugPrint(e.toString());
    }
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
      response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.message);

      // if(_response.body.toString().startsWith('{errors: [{code:')) {
      //   ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
      //   _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors[0].message);
      // }else if(_response.body.toString().startsWith('{message')) {
      //   _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _response.body['message']);
      // }
      // response0 = Response(
      //   statusCode: response0.statusCode,
      //   body: response0.body,
      // );
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: somethingWentWrong);
    }

    debugPrint(
        '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    // log.e("Handle Response error} ");
    return response0;
  }
}

class MultipartBody {
  String key;
  File file;

  MultipartBody(this.key, this.file);
}

class MultipartListBody {
  String key;
  String value;
  MultipartListBody(this.key, this.value);
}

class ErrorResponse {
  final String? status;
  final int? statusCode;
  final String? message;

  ErrorResponse({
    this.status,
    this.statusCode,
    this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
      );
}
 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';


import '../helper/shared_prefe/shared_prefe.dart';
import '../utils/app_const/app_const.dart';
import 'api_url.dart';

class ApiClient extends GetxService {
  static var client = http.Client();

  static const String somethingWentWrong = "Something Went Wrong";
  static const int timeoutInSeconds = 30;

  static String bearerToken =
      "zI0NTAwODI4fQ.dTr7dcjgfk9ChQ2oZQ39MGZBQSntiT8YjvZTZowUXas";


  static Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': bearerToken
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');

      http.Response response = await client
          .get(
            Uri.parse(ApiUrl.baseUrl + uri),
            headers: headers ?? mainHeaders,
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('------------${e.toString()}');
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  ///========================= Review create or update =========================
  /// patient, therapist, rating, comment

static Future<Response> submitFeedback({
  required String patientId,
  required String therapistId,
  required double rating,
  required String comment,
}) async {
  final body = jsonEncode({
    "patient": patientId,
    "therapist": therapistId,
    "rating": rating,
    "comment": comment,
  });

  return await postData(
    ApiUrl.feedbackCreateOrUpdate,
    body,
  );
}

  static Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool isContentType = true}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = isContentType
        ? {
            'Content-Type': 'application/json',
            'Authorization': bearerToken
          }
        : {
            'Accept': 'application/json',
            'Authorization': bearerToken
          };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await client
          .post(
            Uri.parse(ApiUrl.baseUrl + uri),
            body: body,
            headers: headers ?? mainHeaders,
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e, s) {
      debugPrint('Error------------${e.toString()}');
      debugPrint('S------------${s.toString()}');

      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }


  static Future<Response> patchData(String uri, dynamic body,
    {Map<String, String>? headers, bool isContentType = true}) async {
  bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

  var mainHeaders = isContentType
      ? {
          'Content-Type': 'application/json',
          'Authorization': bearerToken
        }
      : {
          'Accept': 'application/json',
          'Authorization': bearerToken
        };

  try {
    debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
    debugPrint('====> API Body: $body');

    // ✅ FIX: ensure body is JSON string if content-type is application/json
    final requestBody =
        (isContentType && body is! String) ? jsonEncode(body) : body;

    http.Response response = await client
        .patch(
          Uri.parse(ApiUrl.baseUrl + uri),
          body: requestBody,
          headers: headers ?? mainHeaders,
        )
        .timeout(const Duration(seconds: timeoutInSeconds));

    return handleResponse(response, uri);
  } catch (e) {
    debugPrint('------------${e.toString()}');
    return const Response(statusCode: 1, statusText: somethingWentWrong);
  }
}





  static Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await http
          .put(
            Uri.parse(ApiUrl.baseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? mainHeaders,
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }


  static Future<Response> postMultipartData(String uri, dynamic body,
      {List<MultipartBody>? multipartBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Accept': 'application/json',
        'Authorization': bearerToken
      };

      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');

      var request =
      http.MultipartRequest('POST', Uri.parse(ApiUrl.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");

          var mimeType = lookupMimeType(element.file.path);

          debugPrint("MimeType================$mimeType");

          var multipartImg = await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: MediaType.parse(mimeType!),
          );
          request.files.add(multipartImg);
        });
      }

      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: somethingWentWrong,
          body: content);
    } catch (e) {
      debugPrint('------------${e.toString()}');

      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }


  static Future<Response> patchMultipartData(String uri, dynamic body, {List<MultipartBody>? multipartBody, Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Accept': 'application/json',
      'Authorization': bearerToken
    };

    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');

      var request = http.MultipartRequest('PATCH', Uri.parse(ApiUrl.baseUrl + uri));

      // 1. FIX: Ensure the body is a Map<String, String>
      if (body is Map) {
        request.fields.addAll(body.map((key, value) => MapEntry(key.toString(), value.toString())));
      }

      // 2. FIX: Use a proper for...of loop instead of forEach with async
      if (multipartBody != null && multipartBody.isNotEmpty) {
        for (var element in multipartBody) {
          debugPrint("path : ${element.file.path}");
          
          var mimeType = lookupMimeType(element.file.path);
          debugPrint("MimeType================$mimeType");
          
          var multipartImg = await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          );
          request.files.add(multipartImg);
        }
      }

      request.headers.addAll(mainHeaders);

      // Send request and get response
      http.StreamedResponse streamedResponse = await request.send().timeout(const Duration(seconds: timeoutInSeconds));
      http.Response response = await http.Response.fromStream(streamedResponse);

      debugPrint('====> API Response: [${response.statusCode}}] $uri\n${response.body}');

      // 3. FIX: Use your handleResponse function for consistency
      return handleResponse(response, uri);

    } catch (e) {
      debugPrint('------------ ERROR in patchMultipartData: ${e.toString()}');
      // On network failure or other exception, return a response that ApiChecker can handle
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }


  static Future<Response> putMultipartData(String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
      List<MultipartListBody>? multipartListBody,
      Map<String, String>? headers}) async {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': bearerToken
      };

      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');

      //http.MultipartRequest _request = http.MultipartRequest('POST', Uri.parse("https://b936-114-130-157-130.ngrok-free.app/api/v1/user/profile/store/degree"));
      //_request.headers.addAll(headers ?? mainHeaders);
      // for(MultipartBody multipart in multipartBody!) {
      //   if(multipart.file != null) {
      //     Uint8List _list = await multipart.file.readAsBytes();
      //     _request.files.add(http.MultipartFile(
      //       multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
      //       filename: '${DateTime.now().toString()}.png',
      //     ));
      //   }
      // }

      var request =
          http.MultipartRequest('PUT', Uri.parse(ApiUrl.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");

          if (element.file.path.contains(".mp4")) {
            debugPrint("media type mp4 ==== ${element.file.path}");
            request.files.add(http.MultipartFile(
              element.key,
              element.file.readAsBytes().asStream(),
              element.file.lengthSync(),
              filename: 'video.mp4',
              contentType: MediaType('video', 'mp4'),
            ));
          } else if (element.file.path.contains(".png")) {
            debugPrint("media type png ==== ${element.file.path}");
            request.files.add(http.MultipartFile(
              element.key,
              element.file.readAsBytes().asStream(),
              element.file.lengthSync(),
              filename: 'image.png',
              contentType: MediaType('image', 'png'),
            ));
          }

          //request.files.add(await http.MultipartFile.fromPath(element.key, element.file.path,contentType: MediaType('video', 'mp4')));
        });
      }

      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: somethingWentWrong,
          body: content);
    } catch (e) {
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  static Future<Response> deleteData(String uri,
      {Map<String, String>? headers, dynamic body}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': bearerToken
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Call: $uri\n Body: $body');

      http.Response response = await http
          .delete(Uri.parse(ApiUrl.baseUrl + uri),
              headers: headers ?? mainHeaders, body: body)
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: somethingWentWrong);
    }
  }

  static Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      debugPrint(e.toString());
    }
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
      response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.message);

      // if(_response.body.toString().startsWith('{errors: [{code:')) {
      //   ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
      //   _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors[0].message);
      // }else if(_response.body.toString().startsWith('{message')) {
      //   _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _response.body['message']);
      // }
      // response0 = Response(
      //   statusCode: response0.statusCode,
      //   body: response0.body,
      // );
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: somethingWentWrong);
    }

    debugPrint(
        '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    // log.e("Handle Response error} ");
    return response0;
  }

  static Future<Response> uploadAudioFile(File audioFile) async {
  try {
    // Get token if required
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var headers = {
      'Accept': 'application/json',
      'Authorization': bearerToken,
    };

    var uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.audioupload);

    var request = http.MultipartRequest('POST', uri);

    // ✅ Attach audio file
    var mimeType = lookupMimeType(audioFile.path) ?? 'audio/aac';
    request.files.add(
      await http.MultipartFile.fromPath(
        'files', // change this key name if your API expects a different field
        audioFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    request.headers.addAll(headers);

    debugPrint("🎵 Uploading audio to: $uri");
    debugPrint("🎧 File: ${audioFile.path}");

    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint("✅ Audio upload response [${response.statusCode}]: $responseBody");

    return Response(
      statusCode: response.statusCode,
      body: responseBody,
    );
  } catch (e) {
    debugPrint("❌ Audio upload failed: $e");
    return const Response(statusCode: 1, statusText: somethingWentWrong);
  }
}
}

class MultipartBody {
  String key;
  File file;

  MultipartBody(this.key, this.file);
}

class MultipartListBody {
  String key;
  String value;
  MultipartListBody(this.key, this.value);
}

class ErrorResponse {
  final String? status;
  final int? statusCode;
  final String? message;

  ErrorResponse({
    this.status,
    this.statusCode,
    this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
      );
}

//======reshcedule booking====
// ================== Reschedule Booking ==================


