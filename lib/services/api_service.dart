import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://appadmin.wowapp.app/"; // use localhost for emulator

  /// 1. Login or Signup
  static Future<Map<String, dynamic>> loginOrSignup({
    required int loginType,
    required String email,
    required String identity,
    required String fcmToken,
    String? referralCode,
  }) async {
    final url = Uri.parse("$baseUrl/client/loginOrSignup");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "loginType": loginType,
        "email": email,
        "identity": identity,
        "fcmToken": fcmToken,
        "referralCode": referralCode,
      }),
    );
    return jsonDecode(response.body);
  }

  /// 2. Generate Referral Code
  static Future<Map<String, dynamic>> getReferralCode(String userId) async {
    // Try GET with query first, then POST with body
    final url = Uri.parse("$baseUrl/client/referral/generate");
    try {
      final getRes = await http.get(url.replace(queryParameters: {"userId": userId}), headers: {"Content-Type": "application/json"});
      return jsonDecode(getRes.body);
    } catch (_) {
      final postRes = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({"userId": userId}));
      return jsonDecode(postRes.body);
    }
  }

  /// 3. Download Reel
  static Future<Map<String, dynamic>> downloadReel(String id) async {
    // Prefer POST (per original app behavior), fallback to GET
    final postUrl = Uri.parse("$baseUrl/downloadVideo/");
    try {
      final response = await http.post(
        postUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      return jsonDecode(response.body);
    } catch (_) {
      final getUrl = postUrl.replace(queryParameters: {"id": id});
      final response = await http.get(getUrl, headers: {"Content-Type": "application/json"});
      return jsonDecode(response.body);
    }
  }

  /// 4. Create Poll
  static Future<Map<String, dynamic>> createPoll({
    required String question,
    required List<String> options,
    required String createdBy,
    required String expiresAt,
  }) async {
    final url = Uri.parse("$baseUrl/client/poll/create");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "question": question,
        "options": options,
        "createdBy": createdBy,
        "expiresAt": expiresAt,
      }),
    );
    return jsonDecode(response.body);
  }

  /// 5. Vote on Poll
  static Future<Map<String, dynamic>> voteOnPoll({
    required String pollId,
    required int optionIndex,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/client/poll/vote");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pollId": pollId,
        "optionIndex": optionIndex,
        "userId": userId,
      }),
    );
    return jsonDecode(response.body);
  }

  /// 6. Poll results
  static Future<Map<String, dynamic>> getPollResults({required String pollId}) async {
    final url = Uri.parse("$baseUrl/client/poll/results");
    final response = await http.get(
      url.replace(queryParameters: {"pollId": pollId}),
      headers: {"Content-Type": "application/json"},
    );
    return jsonDecode(response.body);
  }

  
}
