import 'package:flutter/material.dart';
import 'package:timeless_echo/notifier.dart';
import 'package:timeless_echo/game/game.dart';
import 'package:provider/provider.dart';
import 'package:timeless_echo/game/player.dart';

class HealthWidget extends StatefulWidget {
  const HealthWidget({super.key});

  @override
  State<HealthWidget> createState() => _HeathWidgetState();
}

class _HeathWidgetState extends State<HealthWidget> {
  // The scale variable to control the scaling factor
  final double scale = 10.0; // Set the scale to 10 for larger hearts

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);
    int health = controller.game.player.health;

    // Calculate the number of full, half, and empty hearts based on the health
    int full = health ~/ 30;
    int half = (health % 30) >= 15 ? 1 : 0;
    int empty = 3 - full - half;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Full hearts
        ...List.generate(full, (index) {
          return SizedBox(
            width: 150, // Increased the width to increase space between hearts
            height: 150, // Increased the height to match the width
            child: Transform.scale(
              scale: scale, // Apply the scale factor
              child: Image.asset(
                'assets/images/full.png',
                width: 20, // Original size of the heart image (11x11)
                height: 20, // Original size of the heart image (11x11)
                filterQuality: FilterQuality.none, // Keeps pixelation
                // No background color needed, transparency is kept intact
              ),
            ),
          );
        }),

        // Half hearts
        ...List.generate(half, (index) {
          return SizedBox(
            width: 150, // Increased the width to increase space between hearts
            height: 150, // Increased the height to match the width
            child: Transform.scale(
              scale: scale, // Apply the scale factor
              child: Image.asset(
                'assets/images/half.png',
                width: 20, // Original size of the half heart image (11x11)
                height: 20, // Original size of the half heart image (11x11)
                filterQuality: FilterQuality.none, // Keeps pixelation
                // Transparency is preserved by default in PNGs
              ),
            ),
          );
        }),

        // Empty hearts
        ...List.generate(empty, (index) {
          return SizedBox(
            width: 150, // Increased the width to increase space between hearts
            height: 150, // Increased the height to match the width
            child: Transform.scale(
              scale: scale, // Apply the scale factor
              child: Image.asset(
                'assets/images/empty.png',
                color: Colors.grey, // Apply color for empty hearts
                width: 20, // Original size of the empty heart image (11x11)
                height: 20, // Original size of the empty heart image (11x11)
                filterQuality: FilterQuality.none, // Keeps pixelation
                // Transparency in PNG will remain intact
              ),
            ),
          );
        }),
      ],
    );
  }
}
