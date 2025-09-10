import 'package:get/get.dart';
import 'package:Wow/pages/referral_page/controller/referral_controller.dart';

class ReferralBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReferralController());
  }
}


