import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeless_echo/notifier.dart'; // Import the Controller

// Theme toggle widget that switches between dark/light mode with sun/moon icon
class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the controller from the provider
    final controller = Provider.of<Controller>(context);

    return GestureDetector(
      onTap: () {
        // Toggle the theme when the icon is tapped
        controller.toggleTheme();
      },
      child: Container(
        padding:
            const EdgeInsets.all(12), // Increase padding for a bigger circle
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Makes the background circular
          color: Colors.grey[800], // Dark background for the icon
        ),
        child: Icon(
          // Determine whether the current theme is dark or light
          controller.theme.isDark
              ? Icons.brightness_3 // Moon for dark mode
              : Icons.brightness_7, // Sun for light mode
          color: Colors.white, // Icon color (light) for visibility
          size: 40, // Increased icon size
        ),
      ),
    );
  }
}
