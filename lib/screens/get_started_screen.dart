// get_started_screen.dart
import 'package:flutter/material.dart';
import 'auth_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background grid pattern (mock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/grid.png'), // Assume asset exists or use gradient
                  fit: BoxFit.none,
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          // Card mock
          Positioned(
            top: 100,
            left: 50,
            right: 50,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.grey[800]!, Colors.grey[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.wifi, color: Colors.white, size: 16),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.credit_card, color: Colors.orange, size: 24),
                            SizedBox(width: 8),
                            Expanded(child: Text('**** **** **** 4321', style: TextStyle(color: Colors.white, fontSize: 16))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Aditya Singh', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Valid 11/26', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.account_balance, color: Colors.orange, size: 32),
                            const Expanded(child: SizedBox()),
                            Row(
                              children: [
                                Container(width: 40, height: 25, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4))),
                                const SizedBox(width: 4),
                                Container(width: 40, height: 25, decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(4))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Global elements
          Positioned(
            bottom: 100,
            left: 40,
            child: Column(
              children: [
                Icon(Icons.account_balance, color: Colors.purpleAccent, size: 40),
                const SizedBox(height: 8),
                Icon(Icons.star, color: Colors.purpleAccent, size: 20),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.public, color: Colors.green, size: 30),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            right: 40,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.lock, color: Colors.purple, size: 30),
                ),
                const SizedBox(height: 8),
                Icon(Icons.star, color: Colors.purpleAccent, size: 20),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          // Get Started button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}