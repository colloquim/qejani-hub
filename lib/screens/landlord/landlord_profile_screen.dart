// screens/landlord/landlord_profile_screen.dart
import 'package:flutter/material.dart';

class LandlordProfileScreen extends StatelessWidget {
  const LandlordProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(child: const Text('Landlord profile details will go here')),
    );
  }
}
