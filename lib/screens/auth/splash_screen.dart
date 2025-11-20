// screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Keep the delay for aesthetic display purposes
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (user != null) {
        try {
          // Fetch user data to determine role
          final userModel = await DatabaseService().getUserData(user.uid);

          final targetPath = userModel.role == 'renter'
              ? '/renter/home'
              : '/landlord/dashboard';

          // Go to the authenticated home screen, replacing the splash screen
          context.go(targetPath);
        } catch (e) {
          // If user data fetching fails, proceed to onboarding/login
          context.go('/onboarding');
        }
      } else {
        // If no user is logged in, proceed to onboarding/login
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a dark shade of blue for the background
    return const Scaffold(
      backgroundColor: Color(0xFF1976D2), // Deep Blue Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimalist Logo Icon (Large, White)
            Icon(
              Icons.apartment_rounded, // Using a relevant icon
              size: 120,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            // Bold White Title
            Text(
              'Qejani Hub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36, // Slightly larger for prominence
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 50),
            // Simple white spinner during loading/checking auth status
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
