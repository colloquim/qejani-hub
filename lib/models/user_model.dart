// models/user_model.dart
// lib/models/user_model.dart (UPDATED)

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role; // 'renter' or 'landlord'
  final String fullName;
  final DateTime createdAt;
  final List<String> favoriteApartmentIds;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.fullName,
    required this.createdAt,
    // 🔑 NEW: Initialize the list in the constructor
    this.favoriteApartmentIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("User document data is null");
    }
    // Calls the existing fromMap, passing the data and the document ID
    return UserModel.fromMap(data, doc.id);
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    final createdAtTimestamp = data['createdAt'] as Timestamp?;

    List<String> parsedFavorites = [];
    final rawFavorites = data['favoriteApartmentIds'];
    if (rawFavorites is List) {
      parsedFavorites = rawFavorites.map((e) => e.toString()).toList();
    }

    return UserModel(
      uid: id,
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'renter',
      fullName: data['fullName'] as String? ?? 'User',
      createdAt: createdAtTimestamp?.toDate() ?? DateTime(2000),
      favoriteApartmentIds: parsedFavorites,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'fullName': fullName,
      'createdAt': createdAt,
      'favoriteApartmentIds': favoriteApartmentIds,
    };
  }
}
