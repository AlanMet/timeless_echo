import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:timeless_echo/game/map.dart';
import 'package:timeless_echo/notifier.dart';
import 'helpers.dart';
import 'word_and_type.dart';
import 'room.dart';
import 'player.dart';

class Game {
  // Reference to the controller
  late Controller _controller;
  // Map of words to their types
  Map<String, WordType> vocab = {};
  Atlas map = Atlas();
  Player player = Player();

  Game(this._controller);

  void printscrn(String message) {
    _controller.updateText(message);
  }

  Future<void> loadData() async {
    print("Loading data...");
    await loadDictionary();

    await map.loadRooms();
    Room currentRoom = map.getCurrentRoom();
    print("current room: ${currentRoom.name}");
    _controller.updateText("${currentRoom.name}\n${currentRoom.description}");

    print("Data loaded...");
    return;
  }

  Future<void> loadDictionary() async {
    String contents = "";
    try {
      contents = await rootBundle.loadString('assets/words.csv');
    } catch (e) {
      log("Error loading dictionary: $e");
      return;
    }
    for (var line in contents.split('\n')) {
      List<String> values = line.split(',');
      if (values.length == 2) {
        values[0] = values[0].trim();
        switch (values[1].trim()) {
          case "noun":
            vocab[values[0]] = WordType.noun;
            break;
          case "verb":
            vocab[values[0]] = WordType.verb;
            break;
          case "adjective":
            vocab[values[0]] = WordType.adjective;
            break;
          case "determiner":
            vocab[values[0]] = WordType.determiner;
            break;
          case "pronoun":
            vocab[values[0]] = WordType.pronoun;
            break;
          case "preposition":
            vocab[values[0]] = WordType.preposition;
            break;
          default:
            vocab[values[0]] = WordType.other;
            break;
        }
      }
    }
  }

  void parseCommand(String command) {
    final lowercase = command.trim().toLowerCase();
    if (lowercase.isEmpty) {
      print("I beg your pardon?");
    } else {
      List<String> stringList = command.split(RegExp(r'[ .]'));
      processCommand(stringList);
    }
  }

  void processCommand(List<String> command) {
    List<WordAndType> wordandtype = [];
    WordType wordtype;

    for (String word in command) {
      if (vocab.containsKey(word)) {
        wordtype = vocab[word]!;
        if (wordtype == WordType.other) {
          //do nothing
        } else {
          wordandtype.add(WordAndType(word, wordtype));
        }
      }
    }
    runCommand(wordandtype);

    // if (command[0] == 'hello') {
    //   uiController.updateText("Hello there!");
    // } else if (command[0] == 'pulse') {
    //   uiController.pulse(
    //       Colors.white, Colors.blue, const Duration(milliseconds: 500));
    // } else if (command[0] == 'stop') {
    //   uiController.stopPulsing();
    //   uiController.updateText("Pulse stopped");
    // } else if (command[0] == 'page') {
    //   uiController.updatePage(command[1]);
    // } else {
    //   uiController.updateText("I beg your pardon?");
    // }
  }

  void runCommand(List<WordAndType> wordAndType) {
    print("Running command");
    print(map.getCurrentRoom().id);
    Map<String, Function(List<WordAndType>)> commandMap = {
      '[WordType.verb]': processVerb,
      '[WordType.verb, WordType.noun]': processVerbNoun,
      '[WordType.verb, WordType.verb]': processVerbVerb,
      '[WordType.verb, WordType.verb, WordType.verb]': processVerbVerbVerb,
      '[WordType.verb, WordType.preposition, WordType.noun]':
          processVerbPrepositionNoun,
      '[WordType.verb, WordType.noun, WordType.preposition, WordType.noun]':
          processVerbNounPrepositionNoun,
    };
    String commandTypes =
        wordAndType.map((word) => word.type.toString()).toList().toString();
    print(commandTypes);

    if (commandMap.containsKey(commandTypes)) {
      print(commandMap[commandTypes]);
      commandMap[commandTypes]!(wordAndType);
    } else {
      print("I beg your pardon?");
    }
  }

  void processVerb(List<WordAndType> wordAndType) {
    print("Processing verb");
    WordAndType verb = wordAndType[0];
    switch (verb.word) {
      case "stop":
        printscrn("Pulse stopped");
        break;
      case "lightmode":
        _controller.theme.toggleTheme(false);
        printscrn("Light mode activated");
        break;
      case "darkmode":
        _controller.theme.toggleTheme(true);
        print("Dark mode activated");
        break;
      case "i":
      case "inv":
      case "inventory":
        printscrn(player.printInventory());
        break;
      case "describe":
      case "look":
        printscrn("You are in a room");
        break;
      case "north":
      case "n":
        printscrn(map.move("north"));
        break;
      case "northeast":
      case "ne":
        printscrn(map.move("northeast"));
        break;
      case "northwest":
      case "nw":
        printscrn(map.move("northwest"));
        break;
      case "south":
      case "s":
        printscrn(map.move("south"));
        break;
      case "southwest":
      case "sw":
        printscrn(map.move("southwest"));
        break;
      case "southeast":
      case "se":
        printscrn(map.move("southeast"));
        break;
      case "west":
      case "w":
        printscrn(map.move("west"));
        break;
      case "east":
      case "e":
        printscrn(map.move("east"));
        break;
      case "climb":
      case "up":
      case "u":
        printscrn(map.move("up"));
        break;
      case "down":
      case "d":
        printscrn(map.move("down"));
        break;
      case "run":
        printscrn("You run");
        break;
      default:
        printscrn("Sorry I can't ${verb.word}");
        break;
    }
  }

  void processVerbNoun(List<WordAndType> wordAndType) {
    print("Processing verb and noun");
    WordAndType verb = wordAndType[0];
    WordAndType noun = wordAndType[1];
    switch (verb.word) {
      case "take":
        printscrn("You take the ${noun.word}");
        break;
      case "read":
        printscrn("You read the ${noun.word}");
        break;
      case "drop":
        printscrn("You drop the ${noun.word}");
        break;
      case "open":
        printscrn("You open the ${noun.word}");
        break;
      case "close":
        printscrn("You close the ${noun.word}");
        break;
      case "unlock":
        printscrn("You unlock the ${noun.word}");
        break;
      case "examine":
        printscrn("You examine the ${noun.word}");
        break;
      case "use":
        printscrn("You use the ${noun.word}");
        break;
      case "go":
      case "move":
      case "walk":
        printscrn("You go to the ${noun.word}");
        break;
      default:
        printscrn("Sorry I don't know how to ${verb.word} a ${noun.word}");
        break;
    }
  }

  void processVerbVerb(List<WordAndType> wordAndType) {
    WordAndType verb1 = wordAndType[0];
    WordAndType verb2 = wordAndType[1];

    switch (verb1.word) {
      case "go":
      case "move":
      case "run":
        switch (verb2.word) {
          case "north":
          case "n":
            printscrn(map.move("north"));
            break;
          case "northeast":
          case "ne":
            printscrn(map.move("northeast"));
            break;
          case "northwest":
          case "nw":
            printscrn(map.move("northwest"));
            break;
          case "south":
          case "s":
            printscrn(map.move("south"));
            break;
          case "southwest":
          case "sw":
            printscrn(map.move("southwest"));
            break;
          case "southeast":
          case "se":
            printscrn(map.move("southeast"));
            break;
          case "west":
          case "w":
            printscrn(map.move("west"));
            break;
          case "east":
          case "e":
            printscrn(map.move("east"));
            break;
          case "climb":
          case "up":
          case "u":
            printscrn(map.move("up"));
            break;
          case "down":
          case "d":
            printscrn(map.move("down"));
            break;
          default:
            printscrn("Sorry I don't know how to ${verb1.word} ${verb2.word}");
            break;
        }
      default:
        printscrn("Sorry I don't know how to ${verb1.word} ${verb2.word}");
        break;
    }
  }

  void processVerbVerbVerb(List<WordAndType> wordAndType) {
    printscrn("Processing verb and verb and verb");
  }

  void processVerbPrepositionNoun(List<WordAndType> wordAndType) {
    printscrn("Processing verb preposition noun");
  }

  void processVerbNounPrepositionNoun(List<WordAndType> wordAndType) {
    printscrn("Processing verb noun preposition noun");
  }
}
