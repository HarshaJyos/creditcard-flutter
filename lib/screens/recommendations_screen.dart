// lib/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import 'compare_screen.dart';
import 'apply_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recommendations;
  const RecommendationsScreen({super.key, required this.recommendations});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Cashback', 'Travel', 'Fuel', 'High Approval'];

  @override
  Widget build(BuildContext context) {
    final filtered = widget.recommendations.where((card) {
      if (_filter == 'All') return true;
      final category = (card['category'] as String?)?.toLowerCase() ?? '';
      return category.contains(_filter.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Top Cards'),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: Column(
        children: [
          // FILTER BAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Here are your best matches',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: Colors.indigo.shade600,
                    color: Colors.white70,
                    constraints: const BoxConstraints(minHeight: 38, minWidth: 90),
                    isSelected: _filters.map((f) => f == _filter).toList(),
                    onPressed: (i) => setState(() => _filter = _filters[i]),
                    children: _filters
                        .map((f) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(f, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // CARD GRID — NOW WITH PROPER FLEX
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No cards match this filter', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final card = filtered[i];
                      return Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.grey.shade900,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo
                              Container(
                                height: 48,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.indigo, Colors.purple]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.credit_card, color: Colors.white, size: 30),
                              ),
                              const SizedBox(height: 10),

                              // Name
                              Text(
                                card['name']?.toString() ?? 'Premium Card',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Benefits
                              _buildBenefit('Lounge', card['loungeAccess']?.toString() ?? '4'),
                              _buildBenefit('Fuel', card['fuelWaiver']?.toString() ?? '1%'),
                              _buildBenefit('Approval', card['approvalChance']?.toString() ?? 'High'),

                              const Spacer(),

                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ApplyScreen(card: card)),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Apply', style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(40, 40),
                                      side: const BorderSide(color: Colors.white30),
                                    ),
                                    child: const Icon(Icons.bookmark_border, size: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: filtered.length >= 2
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CompareScreen(cards: filtered.take(2).toList())),
              ),
              backgroundColor: Colors.orange.shade700,
              icon: const Icon(Icons.compare_arrows),
              label: const Text("Compare Top 2"),
            )
          : null,
    );
  }

  Widget _buildBenefit(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10.5, color: Colors.white70),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}