// screens/renter/apartment_list_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/apartment.dart'; // Adjust path if needed

// Reusable Featured Card Widget
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

// Reusable List Item Widget
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
