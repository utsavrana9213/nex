import 'package:get/get.dart';
import 'package:Wow/pages/polls_page/model/poll_model.dart';
import 'package:Wow/services/poll_service.dart';

class PollsController extends GetxController {
  final RxList<PollModel> polls = <PollModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPolls();
  }

  Future<void> fetchPolls() async {
    isLoading.value = true;
    try {
      final results = await PollService.instance.fetchActivePolls();
      polls.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> vote(String pollId, int optionIndex) async {
    await PollService.instance.vote(pollId: pollId, optionIndex: optionIndex);
    await fetchPolls();
  }
}


