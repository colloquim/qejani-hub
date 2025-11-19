// screens/renter/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Note: You might want to import 'package:intl/intl.dart' for better date formatting
import '../../../models/booking.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // Use 'late' and check for null on the current user, or handle the case where it's null
  late Future<List<Booking>> _bookingsFuture;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      // Initialize the future only if the user is logged in
      _bookingsFuture =
          DatabaseService().getMyBookings(renterId: currentUser!.uid);
    } else {
      // Handle the case where the user is not logged in (e.g., return an empty list future)
      _bookingsFuture = Future.value([]);
      // You might also want to navigate the user back to the login screen
    }
  }

  // Helper method to format the DateTime
  String _formatDate(DateTime date) {
    // A simple format for display: Day/Month/Year Hour:Minute
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    // If you add the 'intl' package, you can use:
    // return DateFormat('MMM d, yyyy - h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      // Display a message if the user is somehow viewing this screen while logged out
      return const Scaffold(
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

              // Nested FutureBuilder to fetch apartment details for the booking
              return FutureBuilder<Apartment?>(
                future: DatabaseService().getApartmentById(booking.apartmentId),
                builder: (context, aptSnapshot) {
                  // Show a loading indicator or skip if apartment data is not ready/found
                  if (!aptSnapshot.hasData || aptSnapshot.data == null) {
                    // You might return a basic card with just booking info here
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
                              // Optional: Add an error builder for image loading issues
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 60),
                            )
                          : const Icon(Icons.home, size: 60),

                      title: Text(apartment.title),

                      // Use the corrected 'viewingDate' and the helper function
                      subtitle: Text(
                        'Viewing Date: ${_formatDate(booking.viewingDate)}\nStatus: ${booking.status}',
                      ),

                      isThreeLine: true,
                      // You can add an onTap handler to view booking details if needed
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
