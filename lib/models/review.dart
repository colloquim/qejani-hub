// models/review.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String apartmentId; // ID of the apartment being reviewed
  final String userId; // ID of the user who wrote the review
  final int rating; // 1 to 5
  final String content; // Review text
  final Timestamp createdAt; // When the review was submitted

  Review({
    required this.id,
    required this.apartmentId,
    required this.userId,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  // Convert object to a map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'userId': userId,
      'rating': rating,
      'content': content,
      'createdAt': createdAt,
    };
  }

  // Factory constructor to create a Review object from a Firestore document map
  // CRITICAL: Includes the document ID (id) to match DatabaseService usage
  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id, // Use the provided document ID
      apartmentId: map['apartmentId'] ?? '',
      userId: map['userId'] ?? '',
      // Ensure rating is parsed as an integer
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      content: map['content'] ?? '',
      // Ensure timestamp is handled correctly
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
