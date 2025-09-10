import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/polls_page/controller/polls_controller.dart';
import 'package:Wow/routes/app_routes.dart';

class PollsView extends GetView<PollsController> {
  const PollsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.createPollPage),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.polls.isEmpty) {
          return const Center(child: Text('No polls yet'));
        }
        return ListView.builder(
          itemCount: controller.polls.length,
          itemBuilder: (context, index) {
            final poll = controller.polls[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(poll.question, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...List.generate(poll.options.length, (i) {
                      final option = poll.options[i];
                      final total = poll.totalVotes == 0 ? 1 : poll.totalVotes;
                      final percent = (poll.votes.length > i ? poll.votes[i] : 0) / total;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: InkWell(
                          onTap: poll.isExpired ? null : () => controller.vote(poll.id, i),
                          child: Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(value: percent, minHeight: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: Text(option)),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(poll.isExpired ? 'Expired' : 'Active'),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}


