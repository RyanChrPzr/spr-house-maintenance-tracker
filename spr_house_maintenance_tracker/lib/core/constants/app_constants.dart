import 'package:flutter/material.dart';

/// Application-wide constants.
///
/// Service types and recurrence intervals are defined here to ensure
/// consistent values across templates, maintenance tasks, and vendor profiles.
class AppConstants {
  AppConstants._();

  // ── Colour System (UX spec: Visual Design Foundation) ──────────────────────

  // Primary
  static const Color primaryNavy = Color(0xFF1B3A6B);
  static const Color primaryBlue = Color(0xFF2E6BC6);
  static const Color primaryBlueSoft = Color(0xFFD6E4F7);

  // Neutrals
  static const Color backgroundApp = Color(0xFFF8F9FB);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEF0F4);
  static const Color textSecondary = Color(0xFF9BA3B2);
  static const Color textPrimary = Color(0xFF1C2230);

  // Semantic
  static const Color statusSuccess = Color(0xFF4CAF82);
  static const Color statusWarning = Color(0xFFF4A732);
  static const Color statusError = Color(0xFFE05252);

  /// Pre-loaded Filipino home maintenance service types.
  /// Used in: template selection (Story 2.2), vendor onboarding (Story 4.1),
  /// vendor browse filter (Story 5.1).
  static const List<String> serviceTypes = [
    'Aircon Cleaning',
    'Pest Control',
    'Plumbing Check',
    'Septic Tank Pump-out',
    'Rooftop Inspection',
    'Electrical Check',
  ];

  /// Default recurrence interval per service type.
  /// Applied automatically when a template task is added to a schedule.
  static const Map<String, String> defaultRecurrenceIntervals = {
    'Aircon Cleaning': 'quarterly',
    'Pest Control': 'semi-annual',
    'Plumbing Check': 'quarterly',
    'Septic Tank Pump-out': 'annual',
    'Rooftop Inspection': 'semi-annual',
    'Electrical Check': 'annual',
  };

  /// Valid recurrence interval values stored in the database.
  static const List<String> recurrenceOptions = [
    'monthly',
    'quarterly',
    'semi-annual',
    'annual',
  ];

  /// Valid booking status values (mirrors database check constraint).
  static const List<String> bookingStatuses = [
    'requested',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled',
  ];

  /// Valid user type values (mirrors profiles.user_type check constraint).
  static const String userTypeHomeowner = 'homeowner';
  static const String userTypeVendor = 'vendor';
}
