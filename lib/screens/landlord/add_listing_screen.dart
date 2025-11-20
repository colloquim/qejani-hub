// screens/landlord/add_listing_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';

class CreatePropertyScreen extends StatefulWidget {
  const CreatePropertyScreen({super.key});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();

  final List<String> _selectedImagePaths = [];

  String? _selectedType;
  String? _selectedLocation;
  bool _isLoading = false;

  static const Color _primaryBlue = Color(0xFF1976D2);

  final List<String> propertyTypes = const [
    'Studio',
    '1 Bedroom',
    '2 Bedroom',
    '3 Bedroom',
    'Mansionette',
  ];

  final List<String> nairobiLocations = const [
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImagePaths.length < 5) {
      setState(() {
        _selectedImagePaths
            .add('simulated/path/image_${_selectedImagePaths.length + 1}.jpg');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Image simulated added. Total: ${_selectedImagePaths.length}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Maximum 5 images reached.'),
            backgroundColor: Colors.orange),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, color: _primaryBlue.withOpacity(0.7))
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: const TextStyle(color: Colors.black54),
    );
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate() ||
        _selectedType == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select type/location.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload at least one apartment photo.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> finalImageUrls = _selectedImagePaths
          .map((_) => 'https://via.placeholder.com/200')
          .toList();

      final newApartment = Apartment(
        id: '',
        landlordId: DatabaseService().getCurrentUserId()!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        propertyType: _selectedType!,
        location: _selectedLocation!,
        bedrooms: int.parse(_bedsController.text.trim()),
        bathrooms: int.parse(_bathsController.text.trim()),
        images: finalImageUrls,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      await DatabaseService().addApartment(newApartment);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Property listed successfully!'),
            backgroundColor: Colors.green),
      );

      context.go('/landlord/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to list property: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Apartment Photos (Max 5)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImagePaths.length + 1,
            itemBuilder: (context, index) {
              if (index < _selectedImagePaths.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.apartment,
                            size: 40, color: _primaryBlue),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (_selectedImagePaths.length < 5) {
                return GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _primaryBlue.withOpacity(0.5), width: 2),
                      color: _primaryBlue.withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_photo_alternate,
                            color: _primaryBlue, size: 30),
                        SizedBox(height: 4),
                        Text('Add Photo',
                            style:
                                TextStyle(color: _primaryBlue, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Picture'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Property Listing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _primaryBlue,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSelector(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                    'Title (e.g., Modern Studio Apartment)',
                    icon: Icons.title),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Detailed Description',
                    icon: Icons.description),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Monthly Price (e.g., 25000)',
                    icon: Icons.attach_money),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a price.';
                  if (double.tryParse(value) == null)
                    return 'Enter a valid number.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: _inputDecoration('Property Type',
                          icon: Icons.home_work),
                      items: propertyTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select a type.' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      decoration:
                          _inputDecoration('Location', icon: Icons.location_on),
                      items: nairobiLocations.map((loc) {
                        return DropdownMenuItem(value: loc, child: Text(loc));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select a location.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bedsController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Bedrooms', icon: Icons.bed),
                      validator: (value) =>
                          value == null || int.tryParse(value) == null
                              ? 'Number of beds.'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _bathsController,
                      keyboardType: TextInputType.number,
                      decoration:
                          _inputDecoration('Bathrooms', icon: Icons.bathtub),
                      validator: (value) =>
                          value == null || int.tryParse(value) == null
                              ? 'Number of baths.'
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_home_work),
                  label: Text(_isLoading ? 'LISTING...' : 'LIST PROPERTY',
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ImageSource {
  camera,
  gallery,
}
