// screens/renter/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';

// 🔑 CONVERTED to StatefulWidget to manage filter state and data fetching
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State for filtering
  String? _selectedLocation;
  // Future to hold the currently filtered list of apartments
  late Future<List<Apartment>> _apartmentsFuture;

  // Placeholder list of popular Nairobi locations for the filter
  final List<String> nairobiLocations = [
    'All Locations',
    'Kilimani',
    'Westlands',
    'Lavington',
    'Upper Hill',
    'Kileleshwa',
    'Parklands',
    'Karen'
        'Pangani',
    'Gigiri',
    'Riverside',
    'Hurlingham'
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
    'Zambezi'
        'Kahawa'
        'Njiru'
        'Utawala'
        'Kayole'
        'Kariobangi'
        'Mathare'
        'Kibera'
        'Rongai'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with a fetch of all apartments (no filter)
    _fetchApartments();
  }

  // Method to fetch data, applying the current filter
  void _fetchApartments() {
    // If _selectedLocation is 'All Locations' or null, DatabaseService will fetch all.
    String? filterLocation =
        (_selectedLocation == 'All Locations' || _selectedLocation == null)
            ? null
            : _selectedLocation;

    _apartmentsFuture =
        DatabaseService().getAllApartments(location: filterLocation);
    setState(() {}); // Rebuild the FutureBuilders
  }

  // --- Component Builders ---

  // 1. Location Filter & Search
  Widget _buildLocationFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Find Your Next Home",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Dropdown for Location Filtering
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: 'Select a location in Nairobi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            prefixIcon: const Icon(Icons.location_on),
          ),
          // Set initial value to 'All Locations'
          value: _selectedLocation ?? nairobiLocations.first,
          items: nairobiLocations.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLocation = newValue;
            });
            _fetchApartments(); // Re-fetch data whenever the filter changes
          },
        ),

        const SizedBox(height: 12),
        // Dedicated Search Button (for navigating to a full search screen)
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Tap here for advanced search...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          onTap: () => context.go('/search'),
        ),
      ],
    );
  }

  // 2. Featured Section (Horizontal Carousel)
  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedLocation == null || _selectedLocation == 'All Locations'
              ? "Featured Deals"
              : "Featured in $_selectedLocation",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250, // Increased height slightly for better card view
          child: FutureBuilder<List<Apartment>>(
            // 🔑 IMPORTANT: Use the state-managed future for filtering
            future: _apartmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No featured listings found."));
              }

              // Limit to first 3 for featured display
              final featuredList = snapshot.data!.take(3).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredList.length,
                itemBuilder: (context, index) {
                  final apartment = featuredList[index];
                  return _ApartmentCard(apartment: apartment, isFeatured: true);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. All Apartments List
  Widget _buildAllApartmentsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "All Listings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Navigate to a dedicated list screen for better full list experience
            TextButton(
              onPressed: () => context.go('/apartment-list'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Apartment>>(
          // 🔑 IMPORTANT: Use the state-managed future for filtering
          future: _apartmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Error loading data: ${snapshot.error.toString()}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                _selectedLocation == null ||
                        _selectedLocation == 'All Locations'
                    ? "No apartments listed yet."
                    : "No apartments found in $_selectedLocation.",
              ));
            }

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final apartment = snapshot.data![index];
                return _ApartmentCard(apartment: apartment);
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qejani Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.go('/favorites'),
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons
                .logout), // Changed settings icon to logout for easy testing
            onPressed: () async {
              await AuthService().signOut();
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Location Filter Component
            _buildLocationFilter(context),
            const SizedBox(height: 24),

            // 2. Featured Section (Horizontal Scroll)
            _buildFeaturedSection(context),
            const SizedBox(height: 24),

            // 3. All Apartments Section
            _buildAllApartmentsList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/my-bookings'),
        child: const Icon(Icons.book_online),
        tooltip: 'My Bookings',
      ),
    );
  }
}

// --- Reusable Apartment Card Widget (Kept as StatelessWidget for purity) ---
class _ApartmentCard extends StatelessWidget {
  final Apartment apartment;
  final bool isFeatured;

  const _ApartmentCard({required this.apartment, this.isFeatured = false});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isFeatured ? 280 : double.infinity;
    final double imageRatio = isFeatured ? 1.5 : 2.5;

    return InkWell(
      // Navigate to detail screen using a route path that accepts the ID
      onTap: () => context.go('/apartment/${apartment.id}'),
      child: Card(
        margin: EdgeInsets.only(bottom: 16, right: isFeatured ? 16 : 0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              AspectRatio(
                aspectRatio: imageRatio,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    apartment.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                          child:
                              Icon(Icons.image, size: 40, color: Colors.grey)),
                    ),
                  ),
                ),
              ),

              // Text Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ksh ${apartment.price.toStringAsFixed(0)} / mo',
                      style: TextStyle(
                        fontSize: isFeatured ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apartment.title,
                      style: TextStyle(
                        fontSize: isFeatured ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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
