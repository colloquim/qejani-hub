// screens/landlord/edit_listing_screen.dart
import 'package:flutter/material.dart';

class EditListingScreen extends StatelessWidget {
  const EditListingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing')),
      body: Center(child: const Text('Form to edit a listing will go here')),
    );
  }
}
