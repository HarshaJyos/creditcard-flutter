// home_screen.dart (updated with new tabs)
import 'package:flutter/material.dart';
import 'survey_screen.dart';
import 'recommendations_screen.dart'; // But recommendations from survey
import 'rewards_calculator_screen.dart';
import 'track_status_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _checkSurvey();
  }

  Future<void> _checkSurvey() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance.collection('surveys').doc(user.uid).get();
    if (doc.exists) {
      final survey = doc.data()!;
      // Recalculate recommendations similar to survey
      final cardSnap = await FirebaseFirestore.instance.collection('cards').get();
      final cards = cardSnap.docs.map((d) => d.data()).toList();
      final spending = survey['spending'] as Map<String, dynamic>;
      _recommendations = cards.map((card) {
        double score = 0;
        final rewards = card['rewards'] as Map<String, dynamic>? ?? {};
        for (var entry in spending.entries) {
          final cat = entry.key;
          final amount = entry.value as double;
          final rate = rewards[cat] ?? 1.0;
          score += amount * (rate / 100);
        }
        score -= card['annualFee'] ?? 0;
        card['score'] = score;
        return card;
      }).toList()
        ..sort((a, b) => (b['score'] as double).compareTo(a['score'] as double))
        ..take(4).toList();
      setState(() {});
    }
  }

  final _screens = [
    const SurveyScreen(), // If no survey, show this; else recommendations
    const RewardsCalculatorScreen(),
    const TrackStatusScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final firstScreen = _recommendations.isNotEmpty
        ? RecommendationsScreen(recommendations: _recommendations)
        : const SurveyScreen();
    final screens = [firstScreen, ..._screens.sublist(1)];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _selectedIndex == 0 ? [firstScreen] : screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.indigo,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}