import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1527),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Color(0xFF2DD4BF), size: 80),
            const SizedBox(height: 20),
            const Text(
              "App Locked",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Unlock"),
            ),
          ],
        ),
      ),
    );
  }
}
