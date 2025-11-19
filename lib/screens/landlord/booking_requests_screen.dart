// screens/landlord/booking_requests_screen.dart
import 'package:flutter/material.dart';

class BookingRequestsScreen extends StatelessWidget {
  const BookingRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: Center(child: const Text('List of booking requests will go here')),
    );
  }
}
