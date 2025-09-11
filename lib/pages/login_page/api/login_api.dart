import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Wow/pages/login_page/model/login_model.dart';
import 'package:Wow/services/api_service.dart';
import 'package:Wow/utils/api.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/internet_connection.dart';
import 'package:Wow/utils/utils.dart';

import '../../../utils/database.dart';

class LoginApi {
  static Future<LoginModel?> callApi({
    required int loginType,
    required String email,
    required String identity,
    required String fcmToken,
    String? mobileNumber,
    String? userName,
  }) async {
    Utils.showLog("Login Api Calling...");

    final uri = Uri.parse(Api.login);

    final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

    final body = mobileNumber != null
        ? json.encode(
            {
              'mobileNumber': mobileNumber,
              'loginType': loginType,
              'identity': identity,
              "fcmToken": fcmToken,
              if (Database.pendingReferralCode.isNotEmpty) 'referralCode': Database.pendingReferralCode,
            },
          )
        : (userName == null)
            ? json.encode(
                {
                  'email': email,
                  'loginType': loginType,
                  'identity': identity,
                  "fcmToken": fcmToken,
                  if (Database.pendingReferralCode.isNotEmpty) 'referralCode': Database.pendingReferralCode,
                },
              )
            : json.encode(
                {
                  'email': email,
                  'loginType': loginType,
                  'identity': identity,
                  "fcmToken": fcmToken,
                  "name": userName,
                  "userName": userName,
                  if (Database.pendingReferralCode.isNotEmpty) 'referralCode': Database.pendingReferralCode,
                },
              );

    try {
      if (InternetConnection.isConnect.value) {
        Utils.showLog("Login Api Body => ${body}");
        // Preferred: use unified ApiService
        try {
          final Map<String, dynamic> res = await ApiService.loginOrSignup(
            loginType: loginType,
            email: email,
            identity: identity,
            fcmToken: fcmToken,
            referralCode: Database.pendingReferralCode.isEmpty ? null : Database.pendingReferralCode,
          );
          final model = LoginModel.fromJson(res);
          if (model.status == true) {
            await Database.clearPendingReferralCode();
          }
          return model;
        } catch (e) {
          Utils.showLog("ApiService.loginOrSignup failed, fallback to legacy http: $e");
          // Fallback to existing endpoint if needed
          final response = await http.post(uri, headers: headers, body: body);
          if (response.statusCode == 200) {
            Utils.showLog("Login Api Response => ${response.body}");
            final jsonResponse = json.decode(response.body);
            final model = LoginModel.fromJson(jsonResponse);
            if (model.status == true) {
              await Database.clearPendingReferralCode();
            }
            return model;
          } else {
            Utils.showLog(">>>>> Login Api StateCode Error <<<<<");
          }
        }
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      }
    } catch (error) {
      Utils.showLog("Login Api Error => $error");
    }
    return null;
  }
}
