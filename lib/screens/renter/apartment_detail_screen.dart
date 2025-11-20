// screens/renter/apartment_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';

class ApartmentDetailScreen extends StatefulWidget {
  final String apartmentId;

  const ApartmentDetailScreen({super.key, required this.apartmentId});

  @override
  State<ApartmentDetailScreen> createState() => _ApartmentDetailScreenState();
}

class _ApartmentDetailScreenState extends State<ApartmentDetailScreen> {
  Apartment? _apartment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApartment();
  }

  Future<void> _fetchApartment() async {
    try {
      final apartment =
          await DatabaseService().getApartmentById(widget.apartmentId);
      setState(() {
        _apartment = apartment;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching apartment details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Details...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_apartment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Apartment Not Found')),
        body: const Center(
            child: Text('The requested apartment could not be loaded.')),
      );
    }

    final priceFormatter =
        NumberFormat.currency(locale: 'en_KE', symbol: 'Ksh ');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // Image Slider/Header
          SliverAppBar(
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageHeader(_apartment!.images),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${priceFormatter.format(_apartment!.price)} / month',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          _buildStatusTag(_apartment!.isAvailable),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        _apartment!.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(_apartment!.location,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                      const Divider(height: 32),

                      // Key Features
                      _buildKeyFeatures(),
                      const Divider(height: 32),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_apartment!.description,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 50), // Footer spacing
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Fixed bottom action button
      bottomNavigationBar: _buildBottomAction(context, _apartment!),
    );
  }

  // Helper to build the image carousel/header
  Widget _buildImageHeader(List<String> images) {
    if (images.isEmpty) {
      return Image.network(
        'https://via.placeholder.com/600x400.png?text=No+Image',
        fit: BoxFit.cover,
      );
    }
    // Using a simple image for brevity, ideally this is a PageView/Carousel
    return Image.network(
      images.first,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image, size: 50)),
    );
  }

  // Helper to build the status tag
  Widget _buildStatusTag(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAvailable ? 'AVAILABLE' : 'RENTED',
        style: TextStyle(
          color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper to build the feature icons
  Widget _buildKeyFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeatureItem(Icons.bed, _apartment!.bedrooms, 'Bedrooms'),
        _buildFeatureItem(Icons.bathtub, _apartment!.bathrooms, 'Bathrooms'),
        _buildFeatureItem(Icons.home, 1, _apartment!.propertyType),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, int count, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.deepOrange),
        const SizedBox(height: 4),
        Text(count.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Helper for the fixed bottom action bar
  Widget _buildBottomAction(BuildContext context, Apartment apartment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: apartment.isAvailable
                  ? () {
                      // Navigate to the booking request screen
                      context.go('/apartment/${apartment.id}/request');
                    }
                  : null, // Disable if rented
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: apartment.isAvailable
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              label: Text(
                apartment.isAvailable ? 'Request Viewing' : 'Rented Out',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
