// widgets/apartment_list_item.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/apartment.dart';
// Note: Adjust the path to Apartment model if necessary

class ApartmentListItem extends StatelessWidget {
  final Apartment apartment;

  const ApartmentListItem({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          apartment.images.isNotEmpty
              ? apartment.images.first
              : 'https://via.placeholder.com/50',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              width: 80,
              height: 80,
              child: Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey)),
            );
          },
        ),
      ),
      title: Text(apartment.title),
      subtitle: Text('Ksh ${apartment.price} / mo in ${apartment.location}'),
      trailing: IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: () => context.go('/apartment/${apartment.id}'),
      ),
      onTap: () => context.go('/apartment/${apartment.id}'),
    );
  }
}
