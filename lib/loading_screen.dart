import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ changed to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 🐶 Dog Animation
            Lottie.asset(
              'assets/animations/dog_walk.json',
              height: 200,
              repeat: true,
            ),

            const SizedBox(height: 20),

            /// ✨ Optional minimal text (you can remove if you want ultra-clean UI)
            const Text(
              "Preparing your feeder...",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}