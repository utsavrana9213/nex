import 'dart:math';
import 'package:get/get.dart';
import 'package:Wow/services/referral_service.dart';
import 'package:Wow/utils/database.dart';

class ReferralController extends GetxController {
  final RxString myCode = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ensureMyCode();
  }

  Future<void> ensureMyCode() async {
    isLoading.value = true;
    try {
      final userId = Database.loginUserId;
      final existing = await ReferralService.instance.getOrCreateCode(userId: userId);
      myCode.value = existing;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> redeem(String code) async {
    final userId = Database.loginUserId;
    return await ReferralService.instance.redeemCode(referredUserId: userId, code: code);
  }
}


