// screens/landlord/my_listings_screen.dart
import 'package:flutter/material.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: Center(child: const Text('List of my listings will go here')),
    );
  }
}
