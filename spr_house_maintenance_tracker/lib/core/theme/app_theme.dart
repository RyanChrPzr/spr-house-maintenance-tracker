import 'package:flutter/material.dart';

/// Application theme configuration.
///
/// Uses Material Design 3 with SPR brand Deep Navy as the seed colour.
/// No custom design system for MVP — Material 3 defaults apply.
class AppTheme {
  AppTheme._();

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3A6B), // Deep Navy (UX spec)
          brightness: Brightness.light,
        ),
      );
}
