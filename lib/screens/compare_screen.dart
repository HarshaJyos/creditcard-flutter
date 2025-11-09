// lib/screens/compare_screen.dart
import 'package:flutter/material.dart';

class CompareScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  const CompareScreen({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compare Cards"),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: cards.isEmpty
          ? const Center(child: Text("No cards to compare"))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: cards.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final card = entry.value;
                  final isWinner = idx == 0;

                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 24),
                    child: Card(
                      elevation: 12,
                      shadowColor: isWinner ? Colors.green : Colors.orange,
                      color: isWinner ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isWinner ? Colors.green : Colors.orange, width: 3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isWinner)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                                  child: const Text("BEST MATCH", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: isWinner ? [Colors.green, Colors.teal] : [Colors.orange, Colors.deepOrange]),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.credit_card, color: Colors.white, size: 36),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      card['name']?.toString() ?? 'Card Name',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildRow("Issuer", card['issuer']?.toString() ?? 'N/A'),
                              _buildRow("Annual Fee", "₹${card['annualFee']?.toString() ?? '0'}"),
                              _buildRow("Reward Rate", card['rewardRate']?.toString() ?? '1-5%'),
                              _buildRow("Signup Bonus", card['signupBonus']?.toString() ?? 'None'),
                              _buildRow("Lounge Access", card['loungeAccess']?.toString() ?? 'No'),
                              _buildRow("Fuel Waiver", card['fuelWaiver']?.toString() ?? '1%'),

                              const SizedBox(height: 16),
                              const Text("Key Benefits", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (card['benefits'] as List<dynamic>? ?? [])
                                    .map((b) => Chip(
                                          label: Text(b.toString(), style: const TextStyle(fontSize: 11)),
                                          backgroundColor: Colors.indigo.shade800,
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                              _buildProgress("Cashback", 0.85, Colors.green),
                              _buildProgress("Travel", 0.72, Colors.blue),
                              _buildProgress("Dining", 0.68, Colors.orange),
                              const SizedBox(height: 20),
                              Row(
                                children: List.generate(5, (i) => Icon(Icons.star, color: i < 4 ? Colors.amber : Colors.grey, size: 20)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade800,
          color: color,
          minHeight: 8,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}