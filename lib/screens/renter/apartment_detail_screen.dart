// screens/renter/apartment_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ApartmentDetailScreen extends StatelessWidget {
  // Apartment ID passed via go_router path parameter
  final String apartmentId;

  const ApartmentDetailScreen({Key? key, required this.apartmentId})
      : super(key: key);

  void _showRequestViewingModal(BuildContext context, Apartment apartment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _RequestViewingForm(apartment: apartment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Apartment?>(
        future: DatabaseService().getApartmentById(apartmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading details: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Apartment not found.'));
          }

          final apartment = snapshot.data!;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80.0), // Padding for FAB
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Image Carousel (Mockup)
                    SizedBox(
                      height: 300,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            apartment.images.isNotEmpty
                                ? apartment.images.first
                                : 'https://placehold.co/600x400/CCCCCC/000000?text=Apartment+Image',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey)),
                            ),
                          ),
                          // Optional: Fading effect for aesthetic
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                                stops: const [0, 0.5, 0.7, 1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Details Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ksh ${apartment.price.toStringAsFixed(0)} / month',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${apartment.title} - ${apartment.bedrooms} Bedroom in ${apartment.location}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick Stats (Bed/Bath)
                          Row(
                            children: [
                              _buildStatIcon(
                                  Icons.king_bed, '${apartment.bedrooms} Beds'),
                              _buildStatIcon(Icons.bathtub,
                                  '${apartment.bathrooms} Baths'),
                              _buildStatIcon(
                                  Icons.home_work, apartment.propertyType),
                            ],
                          ),
                          const Divider(height: 32),

                          // Description
                          const Text('Description',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(apartment.description,
                              style: const TextStyle(fontSize: 16)),

                          const Divider(height: 32),

                          // Amenities (Mockup)
                          const Text('Amenities',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildAmenityPill(Icons.wifi, 'Wi-Fi'),
                              _buildAmenityPill(Icons.local_parking, 'Parking'),
                              _buildAmenityPill(
                                  Icons.security, '24/7 Security'),
                              _buildAmenityPill(Icons.pets, 'Pet Friendly'),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Contact/Landlord Info (Placeholder for more advanced feature)
                          Center(
                            child: TextButton.icon(
                              onPressed: () => context.go('/review-property'),
                              icon: const Icon(Icons.rate_review),
                              label: const Text(
                                  'Write a Review for this property'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Action Bar (Request Viewing)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showRequestViewingModal(context, apartment),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Request Viewing',
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAmenityPill(IconData icon, String label) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade100),
    );
  }
}

// --- Request Viewing Form Widget ---
class _RequestViewingForm extends StatefulWidget {
  final Apartment apartment;

  const _RequestViewingForm({required this.apartment});

  @override
  State<_RequestViewingForm> createState() => _RequestViewingFormState();
}

class _RequestViewingFormState extends State<_RequestViewingForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);
      try {
        await DatabaseService().createBooking(
          apartmentId: widget.apartment.id,
          landlordId: widget.apartment.landlordId,
          preferredDate: _selectedDate!,
          message: _messageController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing request sent successfully!')),
        );
        Navigator.pop(context); // Close the modal
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a preferred date.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Viewing',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Property: ${widget.apartment.title}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const Divider(height: 32),

            // Date Picker Field
            InkWell(
              onTap: _isLoading ? null : () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Preferred Viewing Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select a Date'
                      : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Message Field
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Your Message (Optional)',
                hintText: 'e.g., "I am available after 4 PM."',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Request',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
