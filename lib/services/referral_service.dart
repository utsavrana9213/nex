import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
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
      final doc = await _codes.doc(userId).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['code'] as String? ?? '';
      }
      final code = _generateCode(userId);
      await _codes.doc(userId).set({
        'code': code,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      return code;
    } on FirebaseException catch (e) {
      Utils.showLog('Firestore getOrCreateCode error: ${e.code} ${e.message}');
      rethrow;
    }
  }

  Future<bool> redeemCode({required String referredUserId, required String code}) async {
    if (code.isEmpty) return false;
    try {
      // Find who owns the code
      final ownerQuery = await _codes.where('code', isEqualTo: code).limit(1).get();
      if (ownerQuery.docs.isEmpty) return false;
      final ownerId = ownerQuery.docs.first.id;
      if (ownerId == referredUserId) return false; // cannot self-refer

      final useDoc = _uses.doc('$ownerId-$referredUserId');
      final existing = await useDoc.get();
      if (existing.exists) return false; // already used

      await useDoc.set({
        'ownerId': ownerId,
        'referredUserId': referredUserId,
        'code': code,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } on FirebaseException catch (e) {
      Utils.showLog('Firestore redeemCode error: ${e.code} ${e.message}');
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
      if (response.success && response.result != null) {
        return response.result!;
      }
      Utils.showLog('Branch getShortUrl failed: ${response.errorCode} ${response.errorMessage}');
      return '';
    } catch (e) {
      Utils.showLog('Branch link error: $e');
      return '';
    }
  }
}


