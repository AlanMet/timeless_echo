import 'package:flutter/material.dart';

class CustomTheme {
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme([bool? isDark]) {
    if (isDark == null) {
      _isDark = !_isDark;
    } else {
      _isDark = isDark;
    }
  }

  // Updated color scheme
  ColorScheme get _colorScheme => _isDark
      ? const ColorScheme.dark(
          primary: Color(0xFF4A148C), // Rich purple, more sophisticated
          secondary: Color(0xFFFF5722), // Vibrant orange, energetic
          tertiary: Color(0xFFB0BEC5), // Soft grey for tertiary (muted)
          surface: Color(0xFF121212), // Deep dark surface
          onSurface: Colors.white, // White text on dark surfaces
          onPrimary: Colors.white, // White text on primary
          onSecondary: Colors.black, // Black text on secondary elements
        )
      : const ColorScheme.light(
          primary: Color(0xFF1976D2), // Clean and vibrant blue
          secondary: Color(0xFFFF9800), // Warm orange for contrast
          tertiary: Colors.black87, // Black text color, easier readability
          surface: Color(0xFFF5F5F5), // Light grey background
          onSurface: Colors.black, // Black text on light surfaces
          onPrimary: Colors.black, // Black text on primary
          onSecondary: Colors.white, // White text on secondary
        );

  ThemeData get theme {
    return ThemeData(
      brightness: _isDark ? Brightness.dark : Brightness.light,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: _colorScheme.surface,
      primaryColor: _colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: _colorScheme.primary,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: _colorScheme.onSurface),
      ),
    );
  }
}
