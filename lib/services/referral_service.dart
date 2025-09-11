import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:Wow/services/api_service.dart';
import 'package:Wow/utils/utils.dart';

class ReferralService {
  ReferralService._();
  static final ReferralService instance = ReferralService._();

  final _codes = FirebaseFirestore.instance.collection('referral_codes');
  final _uses = FirebaseFirestore.instance.collection('referral_uses');

  String _generateCode(String userId) {
    final rnd = Random(userId.hashCode);
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    return List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<String> getOrCreateCode({required String userId}) async {
    try {
      // 1) Try backend API if available
      try {
        final res = await ApiService.getReferralCode(userId);
        Utils.showLog("🔗 Backend getReferralCode response: $res");
        print("🔗 Backend getReferralCode response: $res");

        // Accept multiple response shapes
        String code = '';
        if (res is Map<String, dynamic>) {
          if ((res['code'] ?? '').toString().isNotEmpty) {
            code = res['code'].toString();
          } else if (res['data'] is Map && (res['data']['code'] ?? '').toString().isNotEmpty) {
            code = res['data']['code'].toString();
          } else if (res['data'] is Map && (res['data']['referralCode'] ?? '').toString().isNotEmpty) {
            code = res['data']['referralCode'].toString();
          }
        }
        if (code.isNotEmpty) {
          return code;
        }
      } catch (e) {
        Utils.showLog('API getReferralCode failed, fallback to Firestore: $e');
        print('API getReferralCode failed, fallback to Firestore: $e');
      }

      // 2) Fallback: Local generation without Firestore (Firestore not configured)
      final code = _generateCode('${userId}_${DateTime.now().millisecondsSinceEpoch}');
      Utils.showLog("✨ Local referral code generated (no Firestore): $code");
      return code;
    } on FirebaseException catch (e) {
      // Firestore missing or unavailable; return a local code instead of throwing
      Utils.showLog('Firestore getOrCreateCode error: ${e.code} ${e.message}');
      final code = _generateCode('${userId}_${DateTime.now().millisecondsSinceEpoch}');
      Utils.showLog("✨ Local referral code generated after Firestore error: $code");
      return code;
    }
  }

  Future<bool> redeemCode({required String referredUserId, required String code}) async {
    if (code.isEmpty) return false;
    try {
      // Find who owns the code
      final ownerQuery = await _codes.where('code', isEqualTo: code).limit(1).get();
      Utils.showLog("🔍 Firestore ownerQuery result: ${ownerQuery.docs}");
      print("🔍 Firestore ownerQuery result: ${ownerQuery.docs}");

      if (ownerQuery.docs.isEmpty) return false;
      final ownerId = ownerQuery.docs.first.id;
      if (ownerId == referredUserId) return false; // cannot self-refer

      final useDoc = _uses.doc('$ownerId-$referredUserId');
      final existing = await useDoc.get();
      if (existing.exists) {
        Utils.showLog("⚠️ Already used referral: ${existing.data()}");
        print("⚠️ Already used referral: ${existing.data()}");
        return false;
      }

      await useDoc.set({
        'ownerId': ownerId,
        'referredUserId': referredUserId,
        'code': code,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      Utils.showLog("✅ Referral redeemed successfully: owner=$ownerId, referred=$referredUserId, code=$code");
      print("✅ Referral redeemed successfully: owner=$ownerId, referred=$referredUserId, code=$code");
      return true;
    } on FirebaseException catch (e) {
      Utils.showLog('Firestore redeemCode error: ${e.code} ${e.message}');
      print('Firestore redeemCode error: ${e.code} ${e.message}');
      return false;
    }
  }

  Future<String> createShareLink({required String code}) async {
    try {
      final meta = BranchContentMetaData()..addCustomMetadata('refCode', code);
      final buo = BranchUniversalObject(
        canonicalIdentifier: 'referral/$code',
        title: 'Join me on Wow',
        contentDescription: 'Use my referral code to join',
        contentMetadata: meta,
      );

      final lp = BranchLinkProperties(
        channel: 'app',
        feature: 'referral',
        campaign: 'user-referral',
      )..addControlParam('refCode', code);

      final response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
      Utils.showLog("🌍 Branch getShortUrl response: success=${response.success}, result=${response.result}, error=${response.errorMessage}");
      print("🌍 Branch getShortUrl response: success=${response.success}, result=${response.result}, error=${response.errorMessage}");

      if (response.success && response.result != null) {
        return response.result!;
      }
      return '';
    } catch (e) {
      Utils.showLog('Branch link error: $e');
      print('Branch link error: $e');
      return '';
    }
  }
}
