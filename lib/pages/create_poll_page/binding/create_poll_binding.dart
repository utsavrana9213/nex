import 'package:get/get.dart';
import 'package:Wow/pages/create_poll_page/controller/create_poll_controller.dart';

class CreatePollBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CreatePollController());
  }
}


