// screens/landlord/edit_listing_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';

class EditListingScreen extends StatefulWidget {
  final String listingId;

  const EditListingScreen({super.key, required this.listingId});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  Apartment? _initialApartment;
  String? _selectedPropertyType;
  int _bedrooms = 1;
  int _bathrooms = 1;
  bool _isAvailable = true;
  bool _isLoading = true; // For initial data load
  bool _isSaving = false; // For submit/delete actions

  final List<String> propertyTypes = ['Apartment', 'House', 'Condo', 'Studio'];

  @override
  void initState() {
    super.initState();
    _loadApartmentData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Fetch the current apartment details and populate controllers
  Future<void> _loadApartmentData() async {
    final apartment =
        await DatabaseService().getApartmentById(widget.listingId);

    if (mounted) {
      if (apartment != null) {
        _initialApartment = apartment;
        _titleController.text = apartment.title;
        _descriptionController.text = apartment.description;
        _priceController.text = apartment.price.toString();
        _locationController.text = apartment.location;

        setState(() {
          _selectedPropertyType = apartment.propertyType;
          _bedrooms = apartment.bedrooms;
          _bathrooms = apartment.bathrooms;
          _isAvailable = apartment.isAvailable;
          _isLoading = false;
        });
      } else {
        // Handle case where apartment is not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Listing not found.'),
              backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false; // Stop loading even on failure
        });
        context.pop(); // Go back
      }
    }
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate() &&
        _selectedPropertyType != null &&
        _initialApartment != null) {
      setState(() => _isSaving = true);

      try {
        // Create an updated Apartment object by combining initial data with controller/state values
        final updatedApartment = Apartment(
          id: widget.listingId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          landlordId: _initialApartment!.landlordId,
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          bedrooms: _bedrooms,
          bathrooms: _bathrooms,
          images: _initialApartment!.images,
          isAvailable: _isAvailable,
          propertyType: _selectedPropertyType!,
          createdAt: _initialApartment!.createdAt,
        );

        await DatabaseService().updateApartment(updatedApartment);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Listing updated successfully!'),
              backgroundColor: Colors.green),
        );
        context.go('/landlord/dashboard');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update listing: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text(
            'Are you sure you want to permanently delete this apartment listing? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => context.pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSaving = true);
      try {
        await DatabaseService().deleteApartment(widget.listingId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Listing deleted successfully.'),
              backgroundColor: Colors.green),
        );
        context.go('/landlord/dashboard');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete listing: $e'),
              backgroundColor: Colors.red),
        );
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Listing')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _confirmAndDelete,
            icon: const Icon(Icons.delete_forever),
            color: Colors.red,
            tooltip: 'Delete Listing',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Listing Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location / City'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration:
                    const InputDecoration(labelText: 'Monthly Price (Ksh)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || double.tryParse(value) == null)
                        ? 'Enter a valid price'
                        : null,
              ),
              const SizedBox(height: 16),

              // Availability Switch
              SwitchListTile(
                title: const Text('Mark as Available'),
                value: _isAvailable,
                onChanged: _isSaving
                    ? null
                    : (bool value) {
                        setState(() => _isAvailable = value);
                      },
                secondary: Icon(_isAvailable
                    ? Icons.check_circle
                    : Icons.do_not_disturb_on),
              ),
              const Divider(),

              // Property Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Property Type'),
                value: _selectedPropertyType,
                items: propertyTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() => _selectedPropertyType = value);
                      },
                validator: (value) =>
                    value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 24),

              // Bedrooms and Bathrooms
              Row(
                children: [
                  Expanded(
                      child: _buildNumberStepper('Bedrooms', _bedrooms,
                          (val) => setState(() => _bedrooms = val), _isSaving)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildNumberStepper(
                          'Bathrooms',
                          _bathrooms,
                          (val) => setState(() => _bathrooms = val),
                          _isSaving)),
                ],
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitUpdate,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving Changes...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for stepper controls
  Widget _buildNumberStepper(
      String label, int value, ValueChanged<int> onChanged, bool isSaving) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed:
                  (value > 1 && !isSaving) ? () => onChanged(value - 1) : null,
            ),
            Text(value.toString(), style: const TextStyle(fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: isSaving ? null : () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}
