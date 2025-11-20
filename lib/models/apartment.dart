// models/apartment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Apartment {
  final String id;
  final String title;
  final String description;
  final String location;
  final String landlordId;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final List<String> images;
  final bool isAvailable;
  final String propertyType;
  final DateTime createdAt; // NEW: Added createdAt

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.landlordId,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.images,
    required this.isAvailable,
    required this.propertyType,
    required this.createdAt, // NEW: Added createdAt
  });

  factory Apartment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Apartment document data is null");
    }

    final createdAtTimestamp = data['createdAt'] as Timestamp?;

    return Apartment(
      id: doc.id,
      title: data['title'] as String? ?? 'N/A',
      description: data['description'] as String? ?? 'No description.',
      location: data['location'] as String? ?? 'Unknown',
      landlordId: data['landlordId'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      bedrooms: (data['bedrooms'] as int?) ?? 0,
      bathrooms: (data['bathrooms'] as int?) ?? 0,
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isAvailable: data['isAvailable'] as bool? ?? true,
      propertyType: data['propertyType'] as String? ?? 'Apartment',
      createdAt: createdAtTimestamp?.toDate() ??
          DateTime(2000), // Handle null timestamp
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'landlordId': landlordId,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'images': images,
      'isAvailable': isAvailable,
      'propertyType': propertyType,
      'createdAt': FieldValue.serverTimestamp(), // Firestore standard practice
    };
  }
}
