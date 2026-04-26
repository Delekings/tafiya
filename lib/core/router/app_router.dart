import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/group_chat/presentation/group_chat_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/savings_wallet/presentation/savings_wallet_screen.dart';
import '../../features/savings_wallet/presentation/create_savings_plan_screen.dart';
import '../../features/tour_details/presentation/tour_details_screen.dart';
import '../../features/tour_discovery/presentation/discover_screen.dart';
import '../../features/guide_network/presentation/guide_enrollment_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // Main shell routes
  static const String home = '/home';
  static const String discover = '/discover';
  static const String savings = '/savings';
  static const String trips = '/trips';
  static const String profile = '/profile';

  // Sub routes
  static const String tourDetails = '/tour/:id';
  static const String booking = '/booking/:id';
  static const String groupChat = '/chat/:bookingId';
  static const String createSavingsPlan = '/savings/create';
  static const String guideEnrollment = '/become-a-guide';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.discover,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: DiscoverScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.savings,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: SavingsWalletScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trips,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: _TripsPlaceholder(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Sub routes (full-screen, outside shell)
      GoRoute(
        path: AppRoutes.tourDetails,
        builder: (_, state) => TourDetailsScreen(
          tourId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.booking,
        builder: (_, state) => BookingScreen(
          tourId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.groupChat,
        builder: (_, state) => GroupChatScreen(
          bookingId: state.pathParameters['bookingId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.createSavingsPlan,
        builder: (_, __) => const CreateSavingsPlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.guideEnrollment,
        builder: (_, __) => const GuideEnrollmentScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

// Temporary placeholder
class _TripsPlaceholder extends StatelessWidget {
  const _TripsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('My Trips — Coming soon')),
    );
  }
}
