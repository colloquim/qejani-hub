// widgets/apartment_card.dart
import 'package:flutter/material.dart';
import '../models/apartment.dart';

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
        // Const added here
        margin: const EdgeInsets.all(8),
        // Const added here
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          // Const added here
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                apartment.title,
                // Const added here
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // These lines read data and cannot be const themselves, but the inner text styling is already handled above.
              Text(apartment.location),
              Text(formatCurrency(apartment.price)),
            ],
          ),
        ),
      ),
    );
  }
}
