// lib/screens/survey_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recommendations_screen.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _monthlyBudgetController = TextEditingController();

  // Fixed: Unique values + meaningful names
  String _primaryCategory = 'General Purpose';

  final Map<String, TextEditingController> _spendingControllers = {
    'groceries': TextEditingController(),
    'fuel': TextEditingController(),
    'dining': TextEditingController(),
    'travel': TextEditingController(),
    'online_shopping': TextEditingController(),
    'utilities': TextEditingController(),
  };

  bool _loading = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _monthlyBudgetController.dispose();
    _spendingControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _submitSurvey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;

    try {
      final surveyData = {
        'userId': user.uid,
        'annualIncome': double.tryParse(_incomeController.text) ?? 0,
        'monthlyBudget': double.tryParse(_monthlyBudgetController.text) ?? 0,
        'primaryCategory': _primaryCategory,
        'spending': {
          for (var e in _spendingControllers.entries)
            e.key: double.tryParse(e.value.text) ?? 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
      };

      await firestore.collection('surveys').doc(user.uid).set(surveyData);

      // Fetch cards and calculate scores
      final cardsSnap = await firestore.collection('cards').get();
      final cards = cardsSnap.docs.map((d) => {...d.data(), 'id': d.id}).toList();

      final spending = surveyData['spending'] as Map<String, dynamic>;
      final recommendations = cards.map((card) {
        double score = 0.0;
        final rewards = card['rewards'] as Map<String, dynamic>? ?? {};

        for (var entry in spending.entries) {
          final category = entry.key;
          final amount = entry.value as double;
          final rate = (rewards[category] ?? 1.0) as num;
          score += amount * (rate.toDouble() / 100);
        }

        // Subtract annual fee
        score -= (card['annualFee'] ?? 0).toDouble();

        return {...card, 'score': score};
      }).toList()
        ..sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

      final top4 = recommendations.take(4).toList();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecommendationsScreen(recommendations: top4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credit Card Survey"),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tell us about your finances to get personalized recommendations.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
                ),
                const SizedBox(height: 24),

                // Annual Income
                TextFormField(
                  controller: _incomeController,
                  decoration: const InputDecoration(
                    labelText: "Annual Income (₹)",
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Monthly Budget
                TextFormField(
                  controller: _monthlyBudgetController,
                  decoration: const InputDecoration(
                    labelText: "Monthly Spending Budget (₹)",
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Primary Category Dropdown - FIXED!
                const Text("Primary Spending Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _primaryCategory,
                  decoration: const InputDecoration(
                    labelText: "Select your main focus",
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "General Purpose", child: Text("General Purpose")),
                    DropdownMenuItem(value: "Cashback", child: Text("Cashback")),
                    DropdownMenuItem(value: "Travel", child: Text("Travel")),
                    DropdownMenuItem(value: "Fuel", child: Text("Fuel")),
                    DropdownMenuItem(value: "Groceries", child: Text("Groceries")),
                    DropdownMenuItem(value: "Dining", child: Text("Dining")),
                    DropdownMenuItem(value: "High Approval", child: Text("High Approval Chance")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _primaryCategory = value!;
                    });
                  },
                  validator: (v) => v == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 24),

                // Monthly Spending by Category
                const Text("Monthly Spending by Category (₹)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ..._spendingControllers.entries.map((e) {
                  final label = e.key.replaceAll('_', ' ').toTitleCase();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: e.value,
                      decoration: InputDecoration(
                        labelText: label,
                        prefixIcon: _getCategoryIcon(e.key),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  );
                }).toList(),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitSurvey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Get My Top 4 Cards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _getCategoryIcon(String key) {
    switch (key) {
      case 'groceries':
        return const Icon(Icons.local_grocery_store);
      case 'fuel':
        return const Icon(Icons.local_gas_station);
      case 'dining':
        return const Icon(Icons.restaurant);
      case 'travel':
        return const Icon(Icons.flight);
      case 'online_shopping':
        return const Icon(Icons.shopping_cart);
      case 'utilities':
        return const Icon(Icons.electrical_services);
      default:
        return const Icon(Icons.category);
    }
  }
}

// Helper extension for title case
extension StringExtension on String {
  String toTitleCase() {
    return split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}