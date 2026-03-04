import 'package:flutter/material.dart';

/// Homeowner dashboard — placeholder for Epic 1.
///
/// Widget key `homeowner_dashboard` is required by integration tests (0.3-INT-001).
class HomeownerDashboardScreen extends StatelessWidget {
  const HomeownerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('homeowner_dashboard'),
      body: Center(child: Text('Homeowner Dashboard — Epic 1')),
    );
  }
}
