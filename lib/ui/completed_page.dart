import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeless_echo/notifier.dart';

class CompletedPage extends StatelessWidget {
  const CompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 38, 126, 41),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Congratulations! You have completed the game!',
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
