// rewards_calculator_screen.dart (new)
import 'package:flutter/material.dart';
import 'estimated_rewards_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsCalculatorScreen extends StatefulWidget {
  const RewardsCalculatorScreen({super.key});

  @override
  State<RewardsCalculatorScreen> createState() => _RewardsCalculatorScreenState();
}

class _RewardsCalculatorScreenState extends State<RewardsCalculatorScreen> {
  final Map<String, TextEditingController> _controllers = {
    'groceries': TextEditingController(),
    'fuel': TextEditingController(),
    'dining': TextEditingController(),
    'travel': TextEditingController(),
    'online_shopping': TextEditingController(),
    'utilities': TextEditingController(),
  };
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final snap = await FirebaseFirestore.instance.collection('cards').get();
    setState(() => _cards = snap.docs.map((d) => d.data()).toList());
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _calculate() {
    final spending = {
      for (var entry in _controllers.entries) entry.key: double.tryParse(entry.value.text) ?? 0,
    };
    final monthlyTotal = spending.values.fold(0.0, (sum, v) => sum + v);
    if (monthlyTotal == 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstimatedRewardsScreen(spending: spending, cards: _cards),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rewards Calculator")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mock image
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/rewards_box.png'), // Assume asset
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Estimate your credit card rewards based on your monthly spending and maximize your benefits."),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ..._controllers.keys.map((key) => TextFormField(
                    controller: _controllers[key],
                    decoration: InputDecoration(
                      labelText: '${key.replaceAll('_', ' ').toUpperCase()}:',
                      suffixIcon: const Icon(Icons.edit),
                    ),
                    keyboardType: TextInputType.number,
                  )),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text("Calculate Rewards"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}