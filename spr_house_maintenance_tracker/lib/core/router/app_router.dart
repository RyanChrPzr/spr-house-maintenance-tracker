import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/vendor/presentation/screens/vendor_onboarding_screen.dart';
import '../../features/vendor/presentation/screens/vendor_profile_setup_screen.dart';
import '../../features/booking/presentation/screens/vendor_profile_screen.dart';

/// Application router — all route definitions live here.
///
/// Route trees:
///   /auth/...      — unauthenticated screens (login, register, role selection)
///   /homeowner/... — homeowner screens (Epic 2, 3, 5)
///   /vendor/...    — vendor screens (Epic 4, 5, 6)
///
/// Role-based redirect guards are added in Story 1.3 when auth state is wired.
final GoRouter appRouter = GoRouter(
  initialLocation: '/auth/register',
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Login — Story 0.3')),
      ),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/homeowner',
      builder: (context, state) => const Scaffold(
        key: Key('homeowner_dashboard'),
        body: Center(child: Text('Homeowner Dashboard — Epic 1')),
      ),
    ),
    GoRoute(
      path: '/homeowner/vendor/:vendorId',
      builder: (context, state) => VendorProfileScreen(
        vendorId: state.pathParameters['vendorId']!,
      ),
    ),
    GoRoute(
      path: '/vendor',
      builder: (context, state) => const VendorOnboardingScreen(),
    ),
    GoRoute(
      path: '/vendor/profile-setup',
      builder: (context, state) => const VendorProfileSetupScreen(),
    ),
    GoRoute(
      path: '/vendor/dashboard',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Vendor Dashboard — Story 5.x')),
      ),
    ),
  ],
);
