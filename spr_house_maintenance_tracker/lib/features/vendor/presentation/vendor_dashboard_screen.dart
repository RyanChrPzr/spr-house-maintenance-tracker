import 'package:flutter/material.dart';

/// Vendor dashboard — placeholder for Epic 4.
///
/// Widget key `vendor_dashboard` is required by integration tests (0.3-INT-002).
class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('vendor_dashboard'),
      body: Center(child: Text('Vendor Dashboard — Epic 4')),
    );
  }
}
