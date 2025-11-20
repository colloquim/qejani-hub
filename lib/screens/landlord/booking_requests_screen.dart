// screens/landlord/booking_requests_screen.dart
import 'package:flutter/material.dart';
import '../../../models/booking.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';

class BookingRequestsScreen extends StatelessWidget {
  const BookingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get landlord ID safely
    final landlordId = AuthService().getCurrentUserId();

    if (landlordId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Viewing Requests')),
        body: const Center(child: Text('Error: Landlord not authenticated.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewing Requests'),
      ),
      // 🔑 FIX: The type here must be List<Booking>
      body: FutureBuilder<List<Booking>>(
        future: DatabaseService().getRequestsByLandlord(landlordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading requests: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No pending viewing requests at the moment.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return RequestListItem(request: requests[index]);
            },
          );
        },
      ),
    );
  }
}

class RequestListItem extends StatelessWidget {
  final Booking request;

  const RequestListItem({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Using apartmentId and viewingDate from the Booking model
              'Request for Apartment ID: ${request.apartmentId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Preferred Date: ${request.viewingDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Text('From Renter ID: ${request.renterId}'),
            Text('Message: ${request.message}'),
            const SizedBox(height: 12),

            // ... (Action buttons) ...
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Request Rejected (Placeholder)'),
                          backgroundColor: Colors.red),
                    );
                  },
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Request Accepted (Placeholder)'),
                          backgroundColor: Colors.green),
                    );
                  },
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
