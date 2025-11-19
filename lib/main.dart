// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

// Auth Screens
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

// Renter Screens
import 'screens/renter/home_screen.dart';
import 'screens/renter/search_screen.dart';
import 'screens/renter/apartment_detail_screen.dart';
import 'screens/renter/favorites_screen.dart';
import 'screens/renter/my_bookings_screen.dart';
import 'screens/renter/booking_request_screen.dart';
import 'screens/renter/write_review_screen.dart';

// Landlord Screens
import 'screens/landlord/landlord_dashboard_screen.dart';
import 'screens/landlord/my_listings_screen.dart';
import 'screens/landlord/add_listing_screen.dart';
import 'screens/landlord/edit_listing_screen.dart';
import 'screens/landlord/booking_requests_screen.dart';
import 'screens/landlord/landlord_profile_screen.dart';

// Shared Screens
import 'screens/shared/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/splash',
      routes: [
        // Auth routes
        GoRoute(
            path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen()),

        // Login routes (role required)
        GoRoute(
            path: '/login/renter',
            builder: (context, state) => LoginScreen(role: 'renter')),
        GoRoute(
            path: '/login/landlord',
            builder: (context, state) => LoginScreen(role: 'landlord')),

        GoRoute(
            path: '/signup', builder: (context, state) => const SignupScreen()),
        GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordScreen()),

        // Root/home
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

        // Renter routes
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
            path: '/search', builder: (context, state) => const SearchScreen()),

        // Apartment detail (requires apartmentId)
        GoRoute(
          path: '/apartment-detail',
          builder: (context, state) {
            final apartmentId = state.extra as String;
            return ApartmentDetailScreen(apartmentId: apartmentId);
          },
        ),

        GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen()),
        GoRoute(
            path: '/my-bookings',
            builder: (context, state) => const MyBookingsScreen()),
        GoRoute(
            path: '/write-review',
            builder: (context, state) => const WriteReviewScreen()),

        // Landlord routes
        GoRoute(
            path: '/landlord-dashboard',
            builder: (context, state) => const LandlordDashboardScreen()),
        GoRoute(
            path: '/my-listings',
            builder: (context, state) => const MyListingsScreen()),
        GoRoute(
            path: '/add-listing',
            builder: (context, state) => const AddListingScreen()),
        GoRoute(
            path: '/edit-listing',
            builder: (context, state) => const EditListingScreen()),
        GoRoute(
            path: '/booking-requests',
            builder: (context, state) => const BookingRequestsScreen()),

        // Shared
        GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen()),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );

    return MaterialApp.router(
      title: 'Qejani Hub',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3), brightness: Brightness.light),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        useMaterial3: true,
      ),
    );
  }
}
