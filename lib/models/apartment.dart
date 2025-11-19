// models/apartment.dart
class Apartment {
  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final String landlordId;
  final List<String> images;
  final double latitude;
  final double longitude;
  final int bedrooms;
  final int bathrooms;
  final int sqft;

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.landlordId,
    required this.images,
    required this.latitude,
    required this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
  });

  factory Apartment.fromMap(Map<String, dynamic> data, String id) {
    return Apartment(
      id: id,
      title: data['title'] ?? 'N/A',
      description: data['description'] ?? '',
      location: data['location'] ?? 'Unknown',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      landlordId: data['landlordId'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      sqft: data['sqft'] ?? 0,
    );
  }
}
