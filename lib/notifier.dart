import 'package:flutter/foundation.dart';
import 'ui/themedata.dart';
import 'game/game.dart';

//singleton class for easy access to the controller
class Controller extends ChangeNotifier {
  //instantiates the controller internally
  static final Controller _instance = Controller._internal();
  Controller._internal();

  late Game game;
  String _text = 'Initializing...';
  String get text => _text;
  List<String> _history = [];
  List<String> get history => _history;
  final CustomTheme _theme = CustomTheme();
  CustomTheme get theme => _theme;

  String menu = 'main';

  void setGame(Game game) {
    this.game = game;
  }

  factory Controller() {
    return _instance; // always returns the same insance
  }

  void updateText(String text, [String? mode]) {
    if (mode == null || mode == 'w') {
      _text = parseText(text);
    } else if (mode == 'a') {
      _text += parseText(text);
    }
    _history.add(_text);
    print("Text updated to: $_text");
  }

  void notifyTextListeners() {
    notifyListeners(); // Notify listeners separately
  }

  void updateMenu(String menu) {
    this.menu = menu;
    notifyListeners();
  }

  //issues wityh loading from firebase
  String parseText(String text) {
    return text.replaceAll(r'\n', '\n');
  }

  void toggleTheme([bool? isDark]) {
    theme.toggleTheme(isDark);
    notifyListeners();
  }

  void gameOver() {
    menu = 'Game Over';
  }
}
