// widgets/apartment_card.dart
import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../utils/helpers.dart';

class ApartmentCard extends StatelessWidget {
  final Apartment apartment;
  final VoidCallback onTap;

  const ApartmentCard({
    super.key,
    required this.apartment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                apartment.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(apartment.location),
              Text(formatCurrency(apartment.price)),
            ],
          ),
        ),
      ),
    );
  }
}
