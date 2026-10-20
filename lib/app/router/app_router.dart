import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/auth/presentation/auth_entry_bg.dart';
import 'package:yava_delivery_driver/features/auth/presentation/driver_register_page.dart';
import 'package:yava_delivery_driver/features/transport/customer_offer_page.dart';
import 'package:yava_delivery_driver/features/transport/customer_quick_request_page.dart';
import 'package:yava_delivery_driver/features/auth/presentation/customer_onboarding_page.dart';
import 'package:yava_delivery_driver/features/auth/presentation/driver_onboarding_page.dart';
import 'package:yava_delivery_driver/features/auth/presentation/login_page.dart';
import 'package:yava_delivery_driver/features/auth/presentation/register_page.dart';
import 'package:yava_delivery_driver/features/auth/presentation/role_selection_page.dart';
import 'package:yava_delivery_driver/features/customer/customer_location_page.dart';
import 'package:yava_delivery_driver/features/customer/customer_new_request_page.dart';
import 'package:yava_delivery_driver/features/customer/customer_profile_page.dart';
import 'package:yava_delivery_driver/features/customer/customer_request_page.dart';
import 'package:yava_delivery_driver/features/customer/customer_trips_page.dart';
import 'package:yava_delivery_driver/features/customer/home/customer_home_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_documents_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_offers_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_profile_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_request_detail_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_request_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_tracking_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_trips_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_vehicles_page.dart';
import 'package:yava_delivery_driver/features/driver/driver_wallet_page.dart';
import 'package:yava_delivery_driver/features/driver/home/driver_home_page.dart';
import 'package:yava_delivery_driver/features/onboarding/presentation/onboarding_page.dart';
import 'package:yava_delivery_driver/features/splash/presentation/splash_page.dart';
import 'package:yava_delivery_driver/features/welcome/welcome_page.dart';
import 'package:yava_delivery_driver/shared/widgets/placeholder_page.dart';



final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: <GoRoute>[
      // ---------------------------------------------------------------------
      // PUBLIC / INITIAL FLOW
      // ---------------------------------------------------------------------
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AuthEntryPage.routePath,
        name: AuthEntryPage.routeName,
        builder: (context, state) => const AuthEntryPage(),
      ),
      GoRoute(
        path: WelcomePage.routePath,
        name: WelcomePage.routeName,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoleSelectionPage.routePath,
        name: RoleSelectionPage.routeName,
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: CustomerOnboardingPage.routePath,
        name: CustomerOnboardingPage.routeName,
        builder: (context, state) => const CustomerOnboardingPage(),
      ),
      GoRoute(
        path: DriverOnboardingPage.routePath,
        name: DriverOnboardingPage.routeName,
        builder: (context, state) => const DriverOnboardingPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = (state.extra as String?) ??
              state.uri.queryParameters['role'] ??
              'client';
          if (role == 'driver') {
            return const DriverRegisterPage();
          }
          return const RegisterPage(role: 'client');
        },
      ),
      GoRoute(
        path: DriverRegisterPage.routePath,
        name: DriverRegisterPage.routeName,
        builder: (context, state) => const DriverRegisterPage(),
      ),

      // ---------------------------------------------------------------------
      // CUSTOMER FLOW
      // ---------------------------------------------------------------------
      GoRoute(
        path: CustomerHomePage.routePath,
        name: CustomerHomePage.routeName,
        builder: (context, state) => const CustomerHomePage(),
      ),
      GoRoute(
        path: CustomerLocationsPage.routePath,
        builder: (context, state) => const CustomerLocationsPage(),
      ),
      GoRoute(
        path: CustomerNewRequestPage.routePath,
        name: CustomerNewRequestPage.routeName,
        builder: (context, state) {
          final service = state.uri.queryParameters['service'] ??
              state.uri.queryParameters['category'];
          return CustomerNewRequestPage(initialService: service);
        },
      ),
      GoRoute(
        path: CustomerRequestsPage.routePath,
        builder: (context, state) => const CustomerRequestsPage(),
      ),
      GoRoute(
        path: '/customer/offers/:requestId',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId'] ?? '1';
          final customerId = state.uri.queryParameters['customerId'] ?? '1';
          return CustomerOffersPage(
            requestId: requestId,
            customerId: customerId,
          );
        },
      ),
      GoRoute(
        path: CustomerTripsPage.routePath,
        builder: (context, state) => const CustomerTripsPage(),
      ),
      _placeholder(
        '/customer/tracking',
        'Trip tracking',
      ),
      GoRoute(
        path: CustomerProfilePage.routePath,
        builder: (context, state) => const CustomerProfilePage(),
      ),

      // ---------------------------------------------------------------------
      // DRIVER FLOW
      // ---------------------------------------------------------------------
      GoRoute(
        path: DriverHomePage.routePath,
        name: DriverHomePage.routeName,
        builder: (context, state) => const DriverHomePage(),
      ),
      GoRoute(
        path: DriverRequestsPage.routePath,
        builder: (context, state) => const DriverRequestsPage(),
      ),
      GoRoute(
        path: '/driver/requests/:requestId',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId'] ?? '1';
          return DriverRequestDetailPage(requestId: requestId);
        },
      ),
      GoRoute(
        path: DriverOffersPage.routePath,
        builder: (context, state) => const DriverOffersPage(),
      ),
      GoRoute(
        path: DriverTripsPage.routePath,
        builder: (context, state) => const DriverTripsPage(),
      ),
    
      GoRoute(
        path: DriverDocumentsPage.routePath,
        builder: (context, state) => const DriverDocumentsPage(),
      ),
      GoRoute(
        path: DriverVehiclesPage.routePath,
        builder: (context, state) => const DriverVehiclesPage(),
      ),
      GoRoute(
        path: DriverWalletPage.routePath,
        builder: (context, state) => const DriverWalletPage(),
      ),
      GoRoute(
        path: DriverProfilePage.routePath,
        builder: (context, state) => const DriverProfilePage(),
      ),

      // ---------------------------------------------------------------------
      // TRANSPORT & DELIVERY SHORTCUTS
      // ---------------------------------------------------------------------
      GoRoute(
        path: DriverTrackingPage.routePath,
        name: 'driver-tracking', // <-- Solución al error de routeName
        builder: (context, state) => const DriverTrackingPage(),
      ),

      // ... (demás rutas intermedias) ...

      // TRANSPORT & DELIVERY SHORTCUTS (Corregido sin llaves extrañas)
      GoRoute(
        path: '/transport/customer-quick-request',
        builder: (context, state) {
          final service = state.uri.queryParameters['category'] ?? 'auto';
          return CustomerQuickRequestPage(service: service);
        },
      ),
      GoRoute(
        path: '/delivery/categories',
        builder: (context, state) => const CustomerQuickRequestPage(service: 'delivery'),
      ),
      GoRoute(
        path: '/delivery/store-list',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? 'restaurantes';
          return CustomerQuickRequestPage(service: category);
        },
      ),
    ],

    errorBuilder: (context, state) {
      return PlaceholderPage(
        title: 'Page not found',
        description: state.error?.toString() ?? 'This route is not available.',
      );
    },
  );
});

GoRoute _placeholder(String path, String title) {
  return GoRoute(
    path: path,
    builder: (context, state) => PlaceholderPage(
      title: title,
    ),
  );
}