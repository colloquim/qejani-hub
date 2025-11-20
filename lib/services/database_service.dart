// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/apartment.dart';
import '../models/booking.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'qejani-hub';

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>> get _apartmentsCollection => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('apartments')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data()!,
        toFirestore: (data, _) => data,
      );

  CollectionReference<Map<String, dynamic>> get _usersCollection => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('users')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data()!,
        toFirestore: (data, _) => data,
      );

  CollectionReference<Map<String, dynamic>> _bookingsCollection(
          String userId) =>
      _db
          .collection('artifacts')
          .doc(_appId)
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data()!,
            toFirestore: (data, _) => data,
          );

  CollectionReference<Map<String, dynamic>> get _publicBookingsCollection => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('bookings')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data()!,
        toFirestore: (data, _) => data,
      );

  Future<void> addApartment(Apartment apartment) async {
    try {
      await _apartmentsCollection.add(apartment.toMap());
      print("Apartment added successfully.");
    } catch (e) {
      print("Error adding apartment: $e");
      throw Exception("Failed to add apartment.");
    }
  }

  Future<List<Apartment>> getApartmentsByLandlord(String landlordId) async {
    try {
      final snapshot = await _apartmentsCollection
          .where('landlordId', isEqualTo: landlordId)
          .get();

      return snapshot.docs.map((doc) => Apartment.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching landlord apartments: $e");
      return [];
    }
  }

  Future<List<Apartment>> getAllApartments({String? location}) async {
    try {
      Query<Map<String, dynamic>> query = _apartmentsCollection;

      if (location != null && location != 'All Locations') {
        query = query.where('location', isEqualTo: location);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Apartment.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching apartments: $e");
      return [];
    }
  }

  Future<Apartment?> getApartmentById(String id) async {
    try {
      final doc = await _apartmentsCollection.doc(id).get();
      if (doc.exists) return Apartment.fromFirestore(doc);
      return null;
    } catch (e) {
      print("Error fetching apartment: $e");
      return null;
    }
  }

  Future<void> updateApartment(Apartment apartment) async {
    try {
      await _apartmentsCollection.doc(apartment.id).update(apartment.toMap());
      print("Apartment updated.");
    } catch (e) {
      print("Error updating apartment: $e");
      throw Exception("Update failed.");
    }
  }

  Future<void> deleteApartment(String apartmentId) async {
    try {
      await _apartmentsCollection.doc(apartmentId).delete();
      print("Apartment deleted.");
    } catch (e) {
      print("Error deleting apartment: $e");
      throw Exception("Delete failed.");
    }
  }

  Future<List<Apartment>> getApartmentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    if (ids.length > 10) ids = ids.sublist(0, 10);

    try {
      final snapshot = await _apartmentsCollection
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return snapshot.docs.map((doc) => Apartment.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching apartments by ids: $e");
      return [];
    }
  }

  Future<List<String>> getFavoriteApartmentIds(String userId) async {
    try {
      final user = await getUserData(userId);
      return user.favoriteApartmentIds;
    } catch (e) {
      print("Error reading favorites: $e");
      return [];
    }
  }

  Future<void> toggleFavorite(String apartmentId, String userId) async {
    final ref = _usersCollection.doc(userId);

    try {
      await _db.runTransaction((txn) async {
        final snap = await txn.get(ref);

        if (!snap.exists) throw Exception("User not found");

        final data = snap.data()!;
        final current = (data['favoriteApartmentIds'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

        if (current.contains(apartmentId)) {
          txn.update(ref, {
            'favoriteApartmentIds': FieldValue.arrayRemove([apartmentId])
          });
        } else {
          txn.update(ref, {
            'favoriteApartmentIds': FieldValue.arrayUnion([apartmentId])
          });
        }
      });
    } catch (e) {
      print("Error toggling favorite: $e");
      throw Exception("Failed to update favorite.");
    }
  }

  Future<void> createBooking({
    required String apartmentId,
    required String landlordId,
    required DateTime preferredDate,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in.");

    final booking = Booking(
      id: '',
      apartmentId: apartmentId,
      renterId: user.uid,
      landlordId: landlordId,
      dateRequested: DateTime.now(),
      viewingDate: preferredDate,
      message: message,
      status: 'Pending',
    );

    try {
      await _bookingsCollection(user.uid).add(booking.toMap());
      await _publicBookingsCollection.add(booking.toMap());
    } catch (e) {
      print("Error creating booking: $e");
      throw Exception("Failed to submit request.");
    }
  }

  Future<List<Booking>> getRequestsByLandlord(String landlordId) async {
    try {
      final snapshot = await _publicBookingsCollection
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('viewingDate')
          .get();

      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error loading landlord requests: $e");
      return [];
    }
  }

  Future<List<Booking>> getMyBookings(String renterId) async {
    try {
      final snapshot = await _bookingsCollection(renterId)
          .orderBy('dateRequested', descending: true)
          .get();

      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error loading bookings: $e");
      return [];
    }
  }

  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();

      if (!doc.exists) throw Exception("User does not exist.");

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print("Error loading user: $e");
      rethrow;
    }
  }

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
      fullName: name ?? 'User',
      createdAt: DateTime.now(),
    );

    try {
      await _usersCollection.doc(uid).set(user.toMap());
      print("User created.");
    } catch (e) {
      print("Error creating user: $e");
      throw Exception("User creation failed.");
    }
  }
}
