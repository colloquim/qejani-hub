// screens/renter/booking_request_screen.dart
import 'package:flutter/material.dart';

class BookingRequestScreen extends StatelessWidget {
  const BookingRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: Center(child: const Text('Booking requests will go here')),
    );
  }
}
