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

  ColorScheme get _colorScheme => _isDark
      ? const ColorScheme.dark(
          primary: Colors.blueGrey,
          secondary: Colors.orange,
          tertiary: Color.fromARGB(255, 196, 196, 196),
          surface: Color.fromARGB(255, 34, 40, 49),
          onSurface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        )
      : const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.orange,
          tertiary: Colors.black,
          surface: Color.fromARGB(40, 40, 41, 255),
          onSurface: Colors.black,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
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
