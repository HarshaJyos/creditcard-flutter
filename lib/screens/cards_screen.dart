import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final selected = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Cards')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cards').snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;

          return ListView(
            children: docs.map((d) {
              final card = d.data() as Map<String, dynamic>;
              final isSelected = selected.contains(card);
              return ListTile(
                title: Text(card['name']),
                subtitle: Text("${card['issuer']} • \$${card['annualFee']}"),
                trailing: IconButton(
                  icon: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                  onPressed: () {
                    setState(() {
                      isSelected ? selected.remove(card) : selected.add(card);
                    });
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: selected.length >= 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompareScreen(cards: selected),
                  ),
                );
              },
              label: const Text("Compare"),
              icon: const Icon(Icons.compare),
            )
          : null,
    );
  }
}

class CompareScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  const CompareScreen({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compare Cards")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cards.map((card) {
            return Card(
              margin: const EdgeInsets.all(10),
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Issuer: ${card['issuer']}"),
                    Text("Annual Fee: \$${card['annualFee']}"),
                    Text("Rewards: ${card['rewardRate']}"),
                    Text("Bonus: ${card['signupBonus']}"),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      children: List<Widget>.from(
                        (card['benefits'] as List).map((b) => Chip(label: Text(b))),
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
