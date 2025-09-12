import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/subscription_page/controller/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Subscription'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Get Verified Badge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Subscribe to unlock verified badge and premium features.'),
                  SizedBox(height: 8),
                  Text('• Verified check mark on profile'),
                  Text('• Priority support'),
                  Text('• Early access to new features'),
                ],
              ),
            ),
            const Spacer(),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isProcessing.value ? null : controller.purchase,
                child: controller.isProcessing.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Subscribe Now'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}


