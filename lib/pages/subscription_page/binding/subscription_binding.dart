import 'package:get/get.dart';
import 'package:Wow/pages/subscription_page/controller/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SubscriptionController());
  }
}


