// widgets/apartment_featured_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/apartment.dart';
// Note: Adjust the path to Apartment model if necessary

class ApartmentFeaturedCard extends StatelessWidget {
  final Apartment apartment;

  const ApartmentFeaturedCard({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/apartment/${apartment.id}'),
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  apartment.images.isNotEmpty
                      ? apartment.images.first
                      : 'https://via.placeholder.com/200',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartment.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Ksh ${apartment.price} / mo',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      apartment.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
