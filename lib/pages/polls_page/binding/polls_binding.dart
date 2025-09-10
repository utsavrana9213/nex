import 'package:get/get.dart';
import 'package:Wow/pages/polls_page/controller/polls_controller.dart';

class PollsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PollsController());
  }
}


