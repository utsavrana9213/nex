import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/services/poll_service.dart';

class CreatePollController extends GetxController {
  final TextEditingController questionController = TextEditingController();
  final RxList<TextEditingController> optionControllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ].obs;
  final RxInt durationHours = 24.obs;
  final RxBool isSubmitting = false.obs;

  void addOption() {
    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length > 2) {
      optionControllers.removeAt(index);
    }
  }

  Future<void> submit() async {
    final question = questionController.text.trim();
    final options = optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (question.isEmpty || options.length < 2) {
      Get.snackbar('Validation', 'Enter question and at least 2 options');
      return;
    }
    isSubmitting.value = true;
    try {
      await PollService.instance.createPoll(
        question: question,
        options: options,
        duration: Duration(hours: durationHours.value),
      );
      if (Get.isOverlaysOpen) Get.back();
      Get.snackbar('Success', 'Poll created');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create poll. Check network or Firestore rules.');
    } finally {
      isSubmitting.value = false;
    }
  }
}


