// apply_screen.dart (new)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'track_status_screen.dart';

class ApplyScreen extends StatefulWidget {
  final Map<String, dynamic> card;
  const ApplyScreen({super.key, required this.card});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  bool _loading = false;

  Future<void> _apply() async {
    final user = FirebaseAuth.instance.currentUser!;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': user.uid,
        'cardId': widget.card['id'], // Assume id in card
        'cardName': widget.card['name'],
        'status': 'Submitted',
        'appliedDate': FieldValue.serverTimestamp(),
        'progress': 1, // Out of 5
        'estimatedApproval': '3-5 business days',
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TrackStatusScreen()),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apply for ${widget.card['name']}")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card details like in gold_reward_card UI
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Reward Rates", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...((widget.card['rewardRate'] as String?)?.split(',') ?? []).map((r) => Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 4), Text(r)])),
                      const SizedBox(height: 10),
                      Text("Annual Fees", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹${widget.card['annualFee'] ?? 0} per year"),
                      const SizedBox(height: 10),
                      Text("Sign Up Bonus", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.card['signupBonus'] ?? ''),
                      const SizedBox(height: 10),
                      Text("Additional Benefits", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...((widget.card['benefits'] as List?) ?? []).map((b) => Text('• $b')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _apply,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text("Apply Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}