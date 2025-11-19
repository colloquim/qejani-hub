// screens/landlord/add_listing_screen.dart
import 'package:flutter/material.dart';

class AddListingScreen extends StatelessWidget {
  const AddListingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: Center(child: const Text('Form to add a listing will go here')),
    );
  }
}
