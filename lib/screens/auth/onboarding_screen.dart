// screens/auth/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the primary color from the theme (which is Blue, based on your main.dart)
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title/Branding
              Text(
                'Welcome to Qejani Hub',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Use primary color for branding
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Renter Button (The Primary Action)
              ElevatedButton.icon(
                // Changed to ElevatedButton.icon
                onPressed: () {
                  context.go('/login/renter');
                },
                icon: const Icon(Icons.person),
                label: const Text('Sign In as Renter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // Landlord Button (The Secondary Action, now styled to match the theme)
              OutlinedButton.icon(
                // Changed to OutlinedButton.icon
                onPressed: () {
                  context.go('/login/landlord');
                },
                icon: Icon(Icons.business,
                    color: primaryColor), // Icon uses primary color
                label: const Text('Sign In as Landlord'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor, // Text color is primary color
                  side: BorderSide(
                      color: primaryColor, width: 2), // Border is primary color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
