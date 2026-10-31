import 'package:flutter/material.dart';

/// Brand red, used as the seed for the Material 3 colour scheme.
const brandRed = Color(0xFFD32F2F);

/// Comfortable line length for reading on tablets and foldables.
const maxReadingWidth = 680.0;

ThemeData buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: brandRed,
    brightness: brightness,
    // keeps the primary colour close to the brand red instead of a pastel
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
    ),
    chipTheme: const ChipThemeData(showCheckmark: false),
    cardTheme: const CardThemeData(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // Android's predictive back animation
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  );
}
