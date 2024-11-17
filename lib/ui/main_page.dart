import 'package:flutter/material.dart';
import 'package:timeless_echo/notifier.dart';
import 'package:timeless_echo/ui/body.dart';
import 'package:timeless_echo/ui/top_bar.dart';
import 'package:timeless_echo/ui/input.dart';
import 'package:provider/provider.dart';
import 'package:timeless_echo/game/game.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeGame();
  }

  Future<void> _initializeGame() async {
    final Controller notifier = Provider.of<Controller>(context, listen: false);
    Game game = Game(notifier);
    await game.loadData();
    notifier.game = game;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the game is loading, show a loading spinner
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // If there's an error loading the game, show an error message
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // When the game is successfully initialized, show the main UI
          return Scaffold(
            body: Container(
              color: Provider.of<Controller>(context)
                  .theme
                  .theme
                  .scaffoldBackgroundColor,
              child: const Column(
                children: [
                  Expanded(flex: 2, child: TopBar()),
                  Expanded(flex: 8, child: Body()),
                  Expanded(flex: 2, child: Center(child: TextInput())),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
