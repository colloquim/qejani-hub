// screens/renter/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/apartment_featured_card.dart';
import '../../widgets/apartment_list_item.dart';

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  String? _selectedLocation;
  late Future<List<Apartment>> _apartmentsFuture;

  final List<String> nairobiLocations = const [
    'All Locations',
    'Kilimani',
    'Westlands',
    'Lavington',
    'Upper Hill',
    'Kileleshwa',
    'Parklands',
    'Karen',
    'Pangani',
    'Gigiri',
    'Riverside',
    'Hurlingham',
    'Ngong Road',
    'Ruaka',
    'Thika Road',
    'Embakasi',
    'South B',
    'Langata',
    'Kasarani',
    'Donholm',
    'Komarock',
    'Mombasa Road',
    'Dandora',
    'Kawangware',
    'Gikambura',
    'Zambezi',
    'Kahawa',
    'Njiru',
    'Utawala',
    'Kayole',
    'Kariobangi',
    'Mathare',
    'Kibera',
    'Rongai',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = nairobiLocations.first;
    _fetchApartments();
  }

  void _fetchApartments() {
    final filterLocation =
        (_selectedLocation == 'All Locations' || _selectedLocation == null)
            ? null
            : _selectedLocation;

    _apartmentsFuture =
        DatabaseService().getAllApartments(location: filterLocation);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qejani Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push('/favorites'), // ✅ Push favorites
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              context.go('/onboarding'); // Go to onboarding after logout
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              items: nairobiLocations
                  .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLocation = value);
                  _fetchApartments();
                }
              },
              decoration: InputDecoration(
                labelText: 'Select Location',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Featured Listings
            const Text(
              'Featured Listings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            FutureBuilder<List<Apartment>>(
              future: _apartmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (_, __) => const Card(
                        margin: EdgeInsets.only(right: 12),
                        child: SizedBox(width: 200, height: 200),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading featured listings.',
                        style: TextStyle(color: Colors.red)),
                  );
                }

                final featured = snapshot.data!.take(3).toList();
                if (featured.isEmpty) {
                  return const Center(
                    child: Text('Nothing featured right now.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    itemBuilder: (context, index) =>
                        ApartmentFeaturedCard(apartment: featured[index]),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // All Apartments
            const Text(
              'All Apartments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Apartment>>(
              future: _apartmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }

                final allApts = snapshot.data!;
                if (allApts.isEmpty) {
                  return const Center(
                      child: Text('No apartments found.',
                          style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allApts.length,
                  itemBuilder: (context, index) =>
                      ApartmentListItem(apartment: allApts[index]),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/my-bookings'),
        child: const Icon(Icons.book_online),
      ),
    );
  }
}
