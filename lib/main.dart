// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

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

// 🔹 Listen to Firebase Auth changes
class StreamAuthNotifier extends ChangeNotifier {
  StreamAuthNotifier(Stream<User?> authStream) {
    authStream.listen((user) => notifyListeners());
  }
}

// 🔹 Redirect based on authentication
String? _redirect(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  final loggedIn = user != null;

  const publicPaths = [
    '/splash',
    '/onboarding',
    '/login/renter',
    '/login/landlord',
    '/signup',
    '/forgot-password'
  ];

  final isPublic = publicPaths.contains(state.uri.path);

  if (!loggedIn && !isPublic) return '/splash';
  return null;
}

// 🔹 GoRouter Setup
final _router = GoRouter(
  initialLocation: '/splash',
  refreshListenable: StreamAuthNotifier(AuthService().user),
  redirect: _redirect,
  routes: [
    // Public screens
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),
    GoRoute(
        path: '/login/renter',
        builder: (context, state) => const LoginScreen(role: 'renter')),
    GoRoute(
        path: '/login/landlord',
        builder: (context, state) => const LoginScreen(role: 'landlord')),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen()),

    // Renter screens (nested under /renter/home)
    GoRoute(
      path: '/renter/home',
      builder: (context, state) => const RenterHomeScreen(),
      routes: [
        GoRoute(
          path: 'favorites', // /renter/home/favorites
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: 'search', // /renter/home/search
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: 'my-bookings', // /renter/home/my-bookings
          builder: (context, state) => const MyBookingsScreen(),
        ),
      ],
    ),

    // Apartment Detail with nested booking request
    GoRoute(
      path: '/apartment/:apartmentId',
      builder: (context, state) {
        final apartmentId = state.pathParameters['apartmentId']!;
        return ApartmentDetailScreen(apartmentId: apartmentId);
      },
      routes: [
        GoRoute(
          path: 'request', // /apartment/:apartmentId/request
          builder: (context, state) {
            final apartmentId = state.pathParameters['apartmentId']!;
            return BookingRequestScreen(apartmentId: apartmentId);
          },
        ),
      ],
    ),

    // Renter write review
    GoRoute(
        path: '/write-review',
        builder: (context, state) => const WriteReviewScreen()),

    // Landlord screens
    GoRoute(
        path: '/landlord/dashboard',
        builder: (context, state) => const LandlordDashboardScreen()),
    GoRoute(
        path: '/landlord/listings',
        builder: (context, state) => const MyListingsScreen()),
    GoRoute(
        path: '/landlord/add',
        // ➡️ FIX 3: Corrected the constructor call to match the class name
        builder: (context, state) => const CreatePropertyScreen()),
    GoRoute(
      path: '/landlord/edit/:listingId',
      builder: (context, state) {
        final listingId = state.pathParameters['listingId']!;
        return EditListingScreen(listingId: listingId);
      },
    ),
    GoRoute(
        path: '/landlord/requests',
        builder: (context, state) => const BookingRequestsScreen()),
    GoRoute(
        path: '/landlord/profile',
        builder: (context, state) => const LandlordProfileScreen()),

    // Shared
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: const Center(child: Text('Page not found')),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Qejani Hub',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        // ... (Theme Data is unchanged)
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
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
