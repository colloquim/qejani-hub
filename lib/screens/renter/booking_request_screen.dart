// screens/renter/booking_request_screen.dart
import 'package:flutter/material.dart';

class BookingRequestScreen extends StatelessWidget {
  final String apartmentId;

  const BookingRequestScreen({super.key, required this.apartmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Viewing')),
      body: Center(
          child: Text('Booking request form for Apartment ID: $apartmentId')),
    );
  }
}
