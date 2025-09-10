import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Wow/services/referral_service.dart';
import 'package:Wow/pages/referral_page/controller/referral_controller.dart';

class ReferralView extends GetView<ReferralController> {
  const ReferralView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Referral')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => controller.isLoading.value
                ? const LinearProgressIndicator()
                : const SizedBox.shrink()),
            const Text('Your referral code:'),
            const SizedBox(height: 8),
            Obx(() => Row(
              children: [
                Expanded(
                  child: SelectableText(
                    controller.myCode.value.isEmpty ? '-' : controller.myCode.value,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    if (controller.myCode.value.isNotEmpty) {
                      final link = await ReferralService.instance.createShareLink(code: controller.myCode.value);
                      final text = link.isNotEmpty
                          ? 'Join me on Wow! ${link}'
                          : 'Join me on Wow! Use my referral code: ${controller.myCode.value}';
                      Share.share(text);
                    }
                  },
                )
              ],
            )),
            const SizedBox(height: 24),
            const Text('Have a code? Redeem it:'),
            const SizedBox(height: 8),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(hintText: 'Enter code'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final ok = await controller.redeem(codeController.text.trim());
                if (ok) {
                  Get.snackbar('Success', 'Referral applied');
                } else {
                  Get.snackbar('Invalid', 'Code not valid or already used');
                }
              },
              child: const Text('Redeem'),
            ),
          ],
        ),
      ),
    );
  }
}


