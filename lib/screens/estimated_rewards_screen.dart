// estimated_rewards_screen.dart (new)
import 'package:flutter/material.dart';

class EstimatedRewardsScreen extends StatelessWidget {
  final Map<String, double> spending;
  final List<Map<String, dynamic>> cards;
  const EstimatedRewardsScreen({super.key, required this.spending, required this.cards});

  @override
  Widget build(BuildContext context) {
    final monthlyTotal = spending.values.fold(0.0, (sum, v) => sum + v);
    final annualTotal = monthlyTotal * 12;

    return Scaffold(
      appBar: AppBar(title: const Text("Estimated Rewards")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Monthly: ₹${monthlyTotal.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Annual: ₹${annualTotal.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (ctx, i) {
                  final card = cards[i];
                  double monthlyRewards = 0;
                  final rewards = card['rewards'] as Map<String, dynamic>? ?? {};
                  for (var entry in spending.entries) {
                    final rate = (rewards[entry.key] ?? 1.0) / 100;
                    monthlyRewards += entry.value * rate;
                  }
                  final annualRewards = monthlyRewards * 12;
                  return Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.credit_card),
                      ),
                      title: Text("${card['issuer'] ?? ''} ${card['name'] ?? ''}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Monthly Rewards: ₹${monthlyRewards.toStringAsFixed(0)}"),
                          Text("Annual Rewards: ₹${annualRewards.toStringAsFixed(0)}"),
                          ...spending.entries.map((e) => Text("${e.key}: ₹${(e.value * ((rewards[e.key] ?? 1.0) / 100)).toStringAsFixed(0)}")),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        child: const Icon(Icons.replay),
      ),
    );
  }
}