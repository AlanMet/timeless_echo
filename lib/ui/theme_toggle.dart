import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeless_echo/notifier.dart'; // Import the Controller

// Theme toggle widget that switches between dark/light mode with sun/moon icon
class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the controller from the provider
    final controller = Provider.of<Controller>(context);

    return GestureDetector(
      onTap: () {
        controller.toggleTheme();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[800],
        ),
        child: Icon(
          controller.theme.isDark ? Icons.brightness_3 : Icons.brightness_7,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
