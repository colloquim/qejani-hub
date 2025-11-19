// models/booking.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String apartmentId;
  final String renterId;
  final String landlordId;
  final DateTime dateRequested;
  final DateTime
      viewingDate; // Changed from startDate/endDate to single viewingDate
  final String message;
  final String status; // e.g., 'Pending', 'Confirmed', 'Cancelled'

  Booking({
    required this.id,
    required this.apartmentId,
    required this.renterId,
    required this.landlordId,
    required this.dateRequested,
    required this.viewingDate, // Updated field
    required this.message,
    required this.status,
  });

  // --- Factory from Firestore ---
  factory Booking.fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Booking document data is null");
    }

    // Safely cast Timestamps to DateTime
    final dateRequestedTimestamp = data['dateRequested'] as Timestamp?;
    final viewingDateTimestamp = data['viewingDate'] as Timestamp?;

    return Booking(
      id: doc.id,
      apartmentId: data['apartmentId'] as String? ?? '',
      renterId: data['renterId'] as String? ?? '',
      landlordId: data['landlordId'] as String? ?? '',
      dateRequested: dateRequestedTimestamp?.toDate() ?? DateTime.now(),
      viewingDate:
          viewingDateTimestamp?.toDate() ?? DateTime.now(), // Updated field
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'Pending',
    );
  }

  // --- To Map for Firestore ---
  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'renterId': renterId,
      'landlordId': landlordId,
      'dateRequested': dateRequested,
      'viewingDate': viewingDate, // Updated field
      'message': message,
      'status': status,
    };
  }
}
