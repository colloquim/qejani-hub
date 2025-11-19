// screens/landlord/landlord_dashboard_screen.dart
import 'package:flutter/material.dart';

class LandlordDashboardScreen extends StatelessWidget {
  const LandlordDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/my-listings');
              },
              child: const Text('My Listings'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/booking-requests');
              },
              child: const Text('Booking Requests'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-listing');
              },
              child: const Text('Add Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
