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
        elevation: 0,
        title: const Text('Polls'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createPollPage),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.polls.isEmpty) {
          return const Center(
            child: Text(
              'No polls yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.polls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final poll = controller.polls[index];
            final statusColor = poll.isExpired ? Colors.redAccent : Colors.green;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          poll.question,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              poll.isExpired ? Icons.history_toggle_off : Icons.circle,
                              size: 10,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              poll.isExpired ? 'Expired' : 'Active',
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(poll.options.length, (i) {
                    final option = poll.options[i];
                    final optionVotes = poll.votes.length > i ? poll.votes[i] : 0;
                    final total = poll.totalVotes == 0 ? 1 : poll.totalVotes;
                    final percent = optionVotes / total;
                    final percentText = ((percent * 100).toStringAsFixed(0)) + '%';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: poll.isExpired ? null : () => controller.vote(poll.id, i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 10,
                                        backgroundColor: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  percentText,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote, size: 16),
                      const SizedBox(width: 6),
                      Text('${poll.totalVotes} votes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}


