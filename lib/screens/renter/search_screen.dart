// screens/renter/search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedLocation;
  RangeValues _priceRange = const RangeValues(0, 500000);
  int _selectedBedrooms = 0; // 0 means all
  late Future<List<Apartment>> _apartmentsFuture;

  final List<String> nairobiLocations = [
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
  ];

  final List<int> bedroomOptions = [0, 1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _fetchApartments();
  }

  void _fetchApartments() {
    String? locationFilter =
        (_selectedLocation == null || _selectedLocation == 'All Locations')
            ? null
            : _selectedLocation;

    _apartmentsFuture =
        DatabaseService().getAllApartments(location: locationFilter);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Location Dropdown ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Location',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedLocation ?? nairobiLocations.first,
              items: nairobiLocations
                  .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedLocation = val);
                _fetchApartments();
              },
            ),
            const SizedBox(height: 16),

            // --- Price Range Slider ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Range (Ksh)'),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 500000,
                  divisions: 100,
                  labels: RangeLabels(
                    _priceRange.start.round().toString(),
                    _priceRange.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() => _priceRange = values);
                  },
                  onChangeEnd: (_) => _fetchApartments(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Bedrooms Dropdown ---
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Bedrooms',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedBedrooms,
              items: bedroomOptions
                  .map((b) => DropdownMenuItem(
                      value: b, child: Text(b == 0 ? 'Any' : b.toString())))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedBedrooms = val!);
                _fetchApartments();
              },
            ),
            const SizedBox(height: 16),

            // --- Apartments List ---
            Expanded(
              child: FutureBuilder<List<Apartment>>(
                future: _apartmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No apartments found.'));
                  }

                  // Filter price and bedrooms on the client side
                  final filtered = snapshot.data!.where((apt) {
                    final inPriceRange = apt.price >= _priceRange.start &&
                        apt.price <= _priceRange.end;
                    final bedroomsMatch = _selectedBedrooms == 0 ||
                        apt.bedrooms == _selectedBedrooms;
                    return inPriceRange && bedroomsMatch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                        child: Text('No apartments match your filters.'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final apt = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: apt.images.isNotEmpty
                              ? Image.network(apt.images.first,
                                  width: 60, fit: BoxFit.cover)
                              : const Icon(Icons.home, size: 60),
                          title: Text(apt.title),
                          subtitle: Text(
                              'Ksh ${apt.price.toStringAsFixed(0)} / mo - ${apt.bedrooms} BR - ${apt.location}'),
                          onTap: () => context.go('/apartment/${apt.id}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
