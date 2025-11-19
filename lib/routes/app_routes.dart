// routes/app_routes.dart
class AppRoutes {
  // Auth routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Renter routes
  static const String home = '/home';
  static const String search = '/search';
  static const String apartmentDetail = '/apartment-detail';
  static const String favorites = '/favorites';
  static const String myBookings = '/my-bookings';
  static const String writeReview = '/write-review';

  // Landlord routes
  static const String landlordDashboard = '/landlord-dashboard';
  static const String myListings = '/my-listings';
  static const String addListing = '/add-listing';
  static const String editListing = '/edit-listing';
  static const String bookingRequests = '/booking-requests';

  // Shared routes
  static const String review = '/review';
  static const String settings = '/settings';
}
