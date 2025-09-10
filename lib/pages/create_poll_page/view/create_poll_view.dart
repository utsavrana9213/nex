import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/create_poll_page/controller/create_poll_controller.dart';

class CreatePollView extends GetView<CreatePollController> {
  const CreatePollView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Poll')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: [
                for (int i = 0; i < controller.optionControllers.length; i++)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.optionControllers[i],
                          decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => controller.removeOption(i),
                      )
                    ],
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: controller.addOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Add option'),
                  ),
                ),
                Row(
                  children: [
                    const Text('Duration (hours): '),
                    DropdownButton<int>(
                      value: controller.durationHours.value,
                      items: const [6, 12, 24, 48, 72]
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.durationHours.value = v;
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.submit,
                  child: controller.isSubmitting.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create'),
                )),
              ],
            )),
          ],
        ),
      ),
    );
  }
}


