import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';

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
        body: Center(child: Text('Homeowner Dashboard — Epic 1')),
      ),
    ),
    GoRoute(
      path: '/vendor',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Vendor Dashboard — Epic 4')),
      ),
    ),
  ],
);
