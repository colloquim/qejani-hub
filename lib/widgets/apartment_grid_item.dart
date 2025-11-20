// widgets/apartment_grid_item.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/apartment.dart';

class ApartmentGridItem extends StatelessWidget {
  final Apartment apartment;

  const ApartmentGridItem({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final priceFormatter =
        NumberFormat.currency(locale: 'en_KE', symbol: 'Ksh ');

    return GestureDetector(
      onTap: () {
        // Navigate to the Apartment Detail screen
        context.go('/apartment/${apartment.id}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    apartment.images.isNotEmpty
                        ? apartment.images.first
                        : 'https://via.placeholder.com/300x200?text=No+Image',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey)),
                  ),
                  // Availability Tag (Existing Logic)
                  if (apartment.isAvailable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Favorite Icon (Will be updated in the next step)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(Icons.favorite_border,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Details Area (Existing Logic)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceFormatter.format(apartment.price),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apartment.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          apartment.location,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeatureTag(Icons.bed, apartment.bedrooms),
                        _buildFeatureTag(Icons.bathtub, apartment.bathrooms),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.deepOrange),
        const SizedBox(width: 4),
        Text('$count', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
