import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/vendor/presentation/screens/vendor_onboarding_screen.dart';
import '../../features/vendor/presentation/screens/vendor_profile_setup_screen.dart';
import '../../features/booking/presentation/screens/vendor_profile_screen.dart';
import '../../features/homeowner/presentation/homeowner_dashboard_screen.dart';
import '../../features/vendor/presentation/vendor_dashboard_screen.dart';

/// Application router — all route definitions live here.
///
/// Route trees:
///   /auth/...      — unauthenticated screens (login, register, role selection)
///   /homeowner/... — homeowner screens (Epic 1, 2, 3)
///   /vendor/...    — vendor screens (Epic 4, 5, 6)
///
/// The [redirect] callback handles two scenarios:
///   1. Unauthenticated user tries to access a protected route → send to login.
///   2. Authenticated user opens the app (session persisted) → send to dashboard.
final GoRouter appRouter = GoRouter(
  initialLocation: '/auth/login',
  redirect: (context, state) async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    final isOnAuth = state.matchedLocation.startsWith('/auth');

    // No session — keep on auth routes, redirect protected routes to login.
    if (session == null) {
      return isOnAuth ? null : '/auth/login';
    }

    // Session exists — redirect auth routes to the role-appropriate dashboard.
    if (isOnAuth) {
      final userId = supabase.auth.currentUser!.id;
      try {
        final profile = await supabase
            .from('profiles')
            .select('user_type')
            .eq('id', userId)
            .single();
        final userType = profile['user_type'] as String;
        return userType == 'homeowner' ? '/homeowner' : '/vendor';
      } catch (_) {
        // Profile fetch failed — fall through to login.
        return '/auth/login';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
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
      builder: (context, state) => const HomeownerDashboardScreen(),
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
      builder: (context, state) => const VendorDashboardScreen(),
    ),
  ],
);
