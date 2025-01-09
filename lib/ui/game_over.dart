import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeless_echo/notifier.dart';

class GameOverPage extends StatelessWidget {
  const GameOverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 138, 31, 31),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Game Over!',
                style: TextStyle(fontSize: 24, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: TextButton(
                onPressed: () {
                  Controller().reset();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'Restart',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
