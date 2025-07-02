import 'package:flutter/material.dart';

class AppColorSchemes {
  // Light Theme Colors
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1E6F5C),
    onPrimary: Colors.white,
    secondary: Color(0xFF29BB89),
    onSecondary: Colors.white,
    tertiary: Color(0xFF4CAF50),
    onTertiary: Colors.white,
    error: Color(0xFFB00020),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xFF121212),
    background: Colors.white,
    onBackground: Color(0xFF121212),
    surfaceVariant: Color(0xFFF3F3F3),
    onSurfaceVariant: Color(0xFF424242),
    outline: Color(0xFFE0E0E0),
  );

  // Dark Theme Colors - Fixed for better visibility
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4DD0A7),  // Brighter green for better visibility
    onPrimary: Color(0xFF000000),  // Black text on primary
    secondary: Color(0xFF66BB6A),  // Light green secondary
    onSecondary: Color(0xFF000000),  // Black text on secondary
    tertiary: Color(0xFF81C784),  // Light green tertiary
    onTertiary: Color(0xFF000000),  // Black text on tertiary
    error: Color(0xFFCF6679),
    onError: Color(0xFF000000),
    surface: Color(0xFF1E1E1E),  // Dark card background
    onSurface: Color(0xFFE1E1E1),  // Light text on dark surface
    background: Color(0xFF121212),  // Dark background
    onBackground: Color(0xFFE1E1E1),  // Light text on dark background
    surfaceVariant: Color(0xFF2C2C2C),  // Slightly lighter dark surface
    onSurfaceVariant: Color(0xFFB0B0B0),  // Medium gray text
    outline: Color(0xFF424242),  // Visible borders in dark mode
  );

  // Sepia Theme Colors
  static const ColorScheme sepiaColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF8C6239), // Muted bronze/rich brown
    onPrimary: Color(0xFFF5EAD6), // Match background
    secondary: Color(0xFFA57D52), // Slightly lighter brown accent
    onSecondary: Color(0xFFF5EAD6), // Match background
    tertiary: Color(0xFFB8956A), // Light brown tertiary
    onTertiary: Color(0xFF4B3A2D), // Dark brown text
    error: Color(0xFFB00020), // Standard error red
    onError: Colors.white,
    surface: Color(0xFFF5EAD6), // Light Beige / Paper-like tone
    onSurface: Color(0xFF4B3A2D), // Dark Brown text
    background: Color(0xFFF0E5D2), // Slightly darker beige background
    onBackground: Color(0xFF4B3A2D), // Dark brown text
    surfaceVariant: Color(0xFFEAE0D0), // Slightly different variant for cards
    onSurfaceVariant: Color(0xFF6B5A4D), // Medium brown text
    outline: Color(0xFFD6C5AE), // Soft divider/border color
  );

  // Custom Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color dividerColor = Color(0xFFD6C5AE);
  static const Color disabledColor = Color(0xFF9E9E9E);
  
  // Dark theme specific colors
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
  static const Color dividerColorDark = Color(0xFF424242);
  static const Color disabledColorDark = Color(0xFF6E6E6E);
}
