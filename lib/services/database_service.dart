// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/apartment.dart';
import '../models/booking.dart';
import '../models/user_model.dart';

// Assuming global variables are available for use in this file:
// const String appId = 'qejani-hub';
// final FirebaseFirestore _db = FirebaseFirestore.instance;

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId =
      'qejani-hub'; // Use a fixed ID for the scope of this file

  // --- Utility for Paths ---
  // Public data is shared across all users (apartments, landlords)
  CollectionReference get _apartmentsCollection => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('apartments');

  CollectionReference get _usersCollection => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('users');

  // Private data for the currently authenticated user (bookings)
  CollectionReference _bookingsCollection(String userId) => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('users')
      .doc(userId)
      .collection('bookings');

  // Public bookings collection for landlord to see all requests
  CollectionReference get _publicBookingsCollection => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('bookings');

  // --- APARTMENT METHODS ---

  Future<List<Apartment>> getAllApartments({String? location}) async {
    try {
      Query query = _apartmentsCollection;
      if (location != null && location != 'All Locations') {
        // This query works best if 'location' is stored as a string, matching the search term.
        query = query.where('location', isEqualTo: location);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Apartment.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching all apartments: $e");
      return [];
    }
  }

  Future<Apartment?> getApartmentById(String id) async {
    try {
      final doc = await _apartmentsCollection.doc(id).get();
      if (doc.exists) {
        return Apartment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error fetching apartment by ID: $e");
      return null;
    }
  }

  // --- BOOKING METHODS ---

  // 🔑 NEW: Method to create a new viewing request (booking)
  Future<void> createBooking({
    required String apartmentId,
    required String landlordId,
    required DateTime preferredDate,
    required String message,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Error: No authenticated user to create booking.");
      throw Exception("User must be signed in to request a viewing.");
    }
    final renterId = currentUser.uid;

    final newBooking = Booking(
      id: '', // Firestore will generate this ID
      apartmentId: apartmentId,
      renterId: renterId,
      landlordId: landlordId,
      dateRequested: DateTime.now(),
      viewingDate: preferredDate,
      message: message,
      status: 'Pending',
    );

    try {
      // 1. Save the booking in the Renter's private collection
      await _bookingsCollection(renterId).add(newBooking.toMap());

      // 2. Save the booking in a public collection for the Landlord to query (optional, but good for cross-user views)
      // A more robust solution might index this by Landlord ID, but for MVP, a public list is fine.
      await _publicBookingsCollection.add(newBooking.toMap());

      print("Booking created successfully!");
    } catch (e) {
      print("Error creating booking: $e");
      throw Exception("Failed to submit booking request.");
    }
  }

  Future<List<Booking>> getMyBookings({required String renterId}) async {
    try {
      final snapshot = await _bookingsCollection(renterId)
          .orderBy('dateRequested', descending: true)
          .get();
      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching my bookings: $e");
      return [];
    }
  }

  // --- USER METHODS ---

  Future<void> createUser({
    required String uid,
    required String email,
    required String role,
    String? name,
  }) async {
    final user = UserModel(
      uid: uid,
      email: email,
      role: role,
      name: name ?? 'User',
      createdAt: DateTime.now(),
    );
    try {
      await _usersCollection.doc(uid).set(user.toMap());
      print("User document created for $role: $uid");
    } catch (e) {
      print("Error creating user document: $e");
    }
  }
}
