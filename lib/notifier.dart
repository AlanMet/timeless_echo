import 'package:flutter/foundation.dart';
import 'ui/themedata.dart';
import 'game/game.dart';

//singleton class for easy access to the controller
class Controller extends ChangeNotifier {
  //instantiates the controller internally
  static final Controller _instance = Controller._internal();
  Controller._internal();

  late Game game;
  void setGame(Game game) {
    this.game = game;
  }

  factory Controller() {
    return _instance; // always returns the same insance
  }

  String _text = 'Initializing...';
  String get text => _text;

  void updateText(String text) {
    _text = parseText(text);
    notifyListeners(); // Notify listeners immediately
    print("Text updated to: $_text");
  }

  //issues wityh loading from firebase
  String parseText(String text) {
    return text.replaceAll(r'\n', '\n');
  }

  final CustomTheme _theme = CustomTheme();
  CustomTheme get theme => _theme;

  void toggleTheme([bool? isDark]) {
    theme.toggleTheme(isDark);
    notifyListeners();
  }
}
