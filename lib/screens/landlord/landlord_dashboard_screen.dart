// screens/landlord/landlord_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/apartment.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  String? _landlordId;
  late Future<List<Apartment>> _myApartmentsFuture;

  static const Color _primaryBlue = Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    _landlordId = AuthService().getCurrentUserId();
    if (_landlordId != null) {
      _fetchMyApartments();
    }
  }

  void _fetchMyApartments() {
    _myApartmentsFuture =
        DatabaseService().getApartmentsByLandlord(_landlordId!);
    setState(() {});
  }

  Widget _buildRequestsSummary(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading:
            const Icon(Icons.calendar_month, color: _primaryBlue, size: 36),
        title: const Text(
          'Pending Viewing Requests',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: _primaryBlue),
        ),
        subtitle: const Text('Tap here to view and manage requests.'),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.black54, size: 16),
        onTap: () {
          context.go('/landlord/requests');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_landlordId == null) {
      // FIX APPLIED HERE: Ensure all children of the const Scaffold are also const.
      return Scaffold(
        appBar: AppBar(title: Text('Landlord Dashboard')),
        body: Center(child: Text('Error: Landlord not authenticated.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _primaryBlue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              context.go('/onboarding');
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestsSummary(context),
            const SizedBox(height: 32),
            const Text(
              'My Apartment Listings',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Apartment>>(
              future: _myApartmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: CircularProgressIndicator(color: _primaryBlue),
                  ));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text('Error loading listings: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                final myApts = snapshot.data ?? [];

                if (myApts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text(
                          'You have no apartments listed yet. Click "Add New Listing" to start.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myApts.length,
                  itemBuilder: (context, index) {
                    return LandlordApartmentListItem(apartment: myApts[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/landlord/add'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_work),
        label: const Text('Add New Listing'),
      ),
    );
  }
}

class LandlordApartmentListItem extends StatelessWidget {
  final Apartment apartment;
  static const Color _primaryBlue = Color(0xFF1976D2);

  const LandlordApartmentListItem({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: apartment.images.isNotEmpty
            ? Image.network(
                apartment.images.first,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            : Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade300,
                child: const Icon(Icons.apartment, color: Colors.grey),
              ),
      ),
      title: Text(
        apartment.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${apartment.location} - Ksh ${apartment.price} / mo',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            context.go('/landlord/edit/${apartment.id}');
          } else if (value == 'status') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Toggling status for ${apartment.title}')),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit, color: _primaryBlue),
              SizedBox(width: 8),
              Text('Edit Listing')
            ]),
          ),
          PopupMenuItem<String>(
            value: 'status',
            child: Row(children: [
              Icon(
                  apartment.isAvailable ? Icons.event_busy : Icons.check_circle,
                  color: apartment.isAvailable ? Colors.orange : Colors.green),
              const SizedBox(width: 8),
              Text(apartment.isAvailable
                  ? 'Mark as Rented'
                  : 'Mark as Available')
            ]),
          ),
        ],
        icon: const Icon(Icons.more_vert, color: Colors.black54),
      ),
      onTap: () => context.go('/apartment/${apartment.id}'),
    );
  }
}
