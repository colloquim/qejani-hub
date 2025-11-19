// screens/renter/apartment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';

class ApartmentListScreen extends StatelessWidget {
  const ApartmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Available Apartments')),
      body: FutureBuilder<List<Apartment>>(
        future: DatabaseService().getAllApartments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading apartments: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No apartments found.'));
          }

          final apartments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apt = apartments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () => context.go('/apartment/${apt.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            apt.images.isNotEmpty
                                ? apt.images.first
                                : 'https://placehold.co/100x100/CCCCCC/000000?text=Home',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Center(
                                  child: Icon(Icons.image,
                                      size: 40, color: Colors.grey)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ksh ${apt.price.toStringAsFixed(0)} / mo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                apt.title,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(apt.location,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.king_bed,
                                      size: 16, color: Colors.grey.shade600),
                                  Text(' ${apt.bedrooms} BR',
                                      style: TextStyle(
                                          color: Colors.grey.shade700)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.bathtub,
                                      size: 16, color: Colors.grey.shade600),
                                  Text(' ${apt.bathrooms} BA',
                                      style: TextStyle(
                                          color: Colors.grey.shade700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
