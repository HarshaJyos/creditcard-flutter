// lib/screens/track_status_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackStatusScreen extends StatelessWidget {
  const TrackStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Applications"),
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('appliedDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          // 2. Has error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            );
          }

          // 3. No data OR empty docs → Show empty state
          final bool hasNoApplications = !snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty;

          if (hasNoApplications) {
            return _buildEmptyState(context);
          }

          // 4. SUCCESS: We have real applications!
          final apps = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, i) {
              final data = apps[i].data() as Map<String, dynamic>;
              final cardName = data['cardName']?.toString() ?? 'Unknown Card';
              final status = data['status']?.toString() ?? 'Processing';
              final progress = (data['progress'] as num?)?.toInt() ?? 1;
              final clampedProgress = progress.clamp(1, 5);
              final appliedDate = (data['appliedDate'] as Timestamp?)?.toDate();
              final estimated = data['estimatedApproval']?.toString() ?? '7-14 days';

              final statuses = [
                'Application Submitted',
                'Document Verification',
                'Bank Review',
                'Final Approval',
                'Card Dispatched & Activated',
              ];

              return Card(
                elevation: 8,
                shadowColor: Colors.indigo.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.grey.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cardName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Applied on: ${appliedDate != null ? _formatDate(appliedDate) : 'Recently'}",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: clampedProgress / 5,
                          backgroundColor: Colors.grey.shade700,
                          color: Colors.indigo.shade400,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$clampedProgress of 5 steps completed",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Estimated approval: $estimated",
                        style: TextStyle(color: Colors.orange.shade300, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),

                      ...List.generate(5, (j) {
                        final isDone = j < clampedProgress;
                        final isCurrent = j == clampedProgress;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone
                                      ? Colors.green
                                      : isCurrent
                                          ? Colors.orange
                                          : Colors.grey.shade600,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: isDone
                                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                                    : isCurrent
                                        ? const Icon(Icons.access_time, size: 16, color: Colors.white)
                                        : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  statuses[j],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDone
                                        ? Colors.white
                                        : isCurrent
                                            ? Colors.orange.shade300
                                            : Colors.grey.shade500,
                                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                const Text(
                                  "In Progress",
                                  style: TextStyle(color: Colors.orange, fontSize: 11),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 100,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 24),
            const Text(
              "No Applications Yet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Apply for your first credit card to start tracking your application status in real-time!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Browse Cards"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    return "${date.day}/${date.month}/${date.year}";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      case 'processing':
      case 'in review':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}