import 'package:flutter/material.dart';
import 'package:timeless_echo/notifier.dart';
import 'TypingEffect.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Controller controller = Controller();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int fontSize = 25;
    if (screenWidth > 1500) {
      fontSize = 50;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Consumer<Controller>(
        builder: (context, controller, child) {
          return TypingText(text: controller.text, uiController: controller);
        },
      ),
    );
  }
}
