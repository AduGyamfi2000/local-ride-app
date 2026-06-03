// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/ride/presentation/screens/user_home_screen.dart';
import '../../features/ride/presentation/screens/request_ride_screen.dart';
import '../../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../../features/ride/presentation/screens/ride_history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_navigation_screen.dart';
import '../../features/driver/presentation/screens/driver_earnings_screen.dart' hide DriverEarningsScreen;
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/ride/presentation/screens/payment_screen.dart';
import '../../features/payment/presentation/screens/wallet_screen.dart';
import '../../features/payment/presentation/screens/add_funds_screen.dart';
import '../constants/app_constants.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String roleSelect = '/role-select';

  // User routes
  static const String userHome = '/user/home';
  static const String requestRide = '/user/request-ride';
  static const String rideTracking = '/user/tracking';
  static const String rideHistory = '/user/history';
  static const String profile = '/user/profile';
  static const String payment = '/payment';
  static const String wallet = '/wallet';
  static const String addFunds = '/add-funds';

  // Driver routes
  static const String driverHome = '/driver/home';
  static const String driverNavigation = '/driver/navigation';
  static const String driverEarnings = '/driver/earnings';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (context, state) => const RoleSelectScreen(),
      ),

      // User routes
      GoRoute(
        path: AppRoutes.userHome,
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestRide,
        builder: (context, state) => const RequestRideScreen(),
      ),
      GoRoute(
        path: AppRoutes.rideTracking,
        builder: (context, state) {
          final rideId = state.extra as String? ?? '';
          return RideTrackingScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: AppRoutes.rideHistory,
        builder: (context, state) => const RideHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return PaymentScreen(
            rideId: args['rideId'] ?? '',
            estimatedFare: args['estimatedFare'] ?? 0.0,
            userId: args['userId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) {
          final userId = state.extra as String? ?? '';
          return WalletScreen(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.addFunds,
        builder: (context, state) {
          final userId = state.extra as String? ?? '';
          return AddFundsScreen(userId: userId);
        },
      ),

      // Driver routes
      GoRoute(
        path: AppRoutes.driverHome,
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverNavigation,
        builder: (context, state) => const DriverNavigationScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverEarnings,
        builder: (context, state) => const DriverEarningsScreen(),
      ),

      // Admin routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyUserToken);
      final role = prefs.getString(AppConstants.keyUserRole);
      final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isAuth = [AppRoutes.login, AppRoutes.otp, AppRoutes.onboarding, AppRoutes.roleSelect]
          .contains(state.matchedLocation);

      if (isSplash) return null; // Let splash handle redirects

      if (token == null && !isAuth) return AppRoutes.login;
      if (token != null && isAuth) {
        return _getHomeForRole(role);
      }
      return null;
    },
  );
}

String _getHomeForRole(String? role) {
  switch (role) {
    case AppConstants.roleDriver:
      return AppRoutes.driverHome;
    case AppConstants.roleAdmin:
      return AppRoutes.adminDashboard;
    default:
      return AppRoutes.userHome;
  }
}
