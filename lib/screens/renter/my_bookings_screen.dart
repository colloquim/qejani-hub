// screens/renter/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/booking.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      // FIX: Changed from named argument (renterId: ...) to positional argument.
      _bookingsFuture = DatabaseService().getMyBookings(currentUser!.uid);
    } else {
      _bookingsFuture = Future.value([]);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Bookings')),
        body: Center(child: Text('Please log in to see your bookings.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No viewing requests made yet.'));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return FutureBuilder<Apartment?>(
                future: DatabaseService().getApartmentById(booking.apartmentId),
                builder: (context, aptSnapshot) {
                  if (!aptSnapshot.hasData || aptSnapshot.data == null) {
                    // This handles cases where the apartment might have been deleted
                    return const SizedBox();
                  }

                  final apartment = aptSnapshot.data!;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: apartment.images.isNotEmpty
                          ? Image.network(
                              apartment.images.first,
                              width: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 60),
                            )
                          : const Icon(Icons.home, size: 60),
                      title: Text(apartment.title),
                      subtitle: Text(
                        'Viewing Date: ${_formatDate(booking.viewingDate)}\nStatus: ${booking.status}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
