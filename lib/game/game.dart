import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:timeless_echo/game/map.dart';
import 'package:timeless_echo/notifier.dart';
import 'helpers.dart';
import 'word_and_type.dart';
import 'room.dart';
import 'interactibles.dart';
import 'player.dart';
import 'item.dart';

//Classes cannot be split in dart
//So sorry for the length of this file
class Game {
  // Reference to the controller
  late final Controller _controller;
  // Map of words to their types
  Map<String, WordType> vocab = {};
  Atlas map = Atlas();
  Player player = Player();
  Game(this._controller);
  get image => map.getCurrentRoom().image;

  void printscrn(String message) {
    _controller.updateText(message);
    _controller.notifyTextListeners();
  }

  Future<void> loadData() async {
    developer.log("Loading data...");
    await loadDictionary();

    //items loaded first so rooms can be filled with items straight away.
    Map<int, dynamic> items = await map.loadItems();
    developer.log(items.toString());
    await map.loadRooms(items);
    Room currentRoom = map.getCurrentRoom();
    developer.log("current room: ${currentRoom.name}");
    if (map.currentRoom is Tutorial) {
      Tutorial tutorial = map.currentRoom as Tutorial;
      String description = tutorial.describe();
      printscrn("$description\n\n${tutorial.steps[0]}");
    } else {
      printscrn(currentRoom.describe());
    }
    developer.log("Data loaded...");
    return;
  }

  /// - Load the dictionary of words and their types
  /// - The dictionary is a CSV file with the following format:
  /// - word, type
  /// - where type is one of the following:
  /// - noun, verb, adjective, determiner, pronoun, preposition
  /// - If the type is not one of the above, it is considered "other"
  Future<void> loadDictionary() async {
    String contents = "";
    try {
      contents = await rootBundle.loadString('assets/words.csv');
    } catch (e) {
      developer.log("Error loading dictionary: $e");
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

  //spooky action at a distance
  void parseCommand(String command) {
    _controller.updateText("");
    //tutorial intercepts commands in order to run the order.
    final lowercase = command.trim().toLowerCase();
    if (lowercase.isEmpty) {
      printscrn("I beg your pardon?");
    } else {
      List<String> stringList = command.split(RegExp(r'[ .]'));
      if (map.currentRoom is Tutorial) {
        map.currentRoom.processCommand(stringList);
        return;
      }
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
  }

  void runCommand(List<WordAndType> wordAndType) {
    developer.log("Running command");
    developer.log("${map.getCurrentRoom().id}");
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

    developer.log(commandTypes);

    if (commandMap.containsKey(commandTypes)) {
      developer.log("running command: ${commandMap[commandTypes]}");
      String output = commandMap[commandTypes]!(wordAndType);
      postProcess(output);
    } else {
      developer.log("I beg your pardon?");
    }
  }

  void postProcess(String output) {
    //if there is an enemy in the room
    //if the enemy is discovered
    //stared = true
    //if started = true
    //allow it to cause damage

    var items = map.getCurrentRoom().items;
    for (var item in items) {
      if (item is Enemy) {
        if (item.started && item.health > 0) {
          output += "\nThe beast attacks you! You take ${item.damage} damage.";
          player.takeDamage(item.damage);
        }
        if (item.discovered) {
          item.started = true;
          developer.log("beast started");
        }
      }
    }
    if (player.health == 100 &&
        map.getCurrentRoom() is Tutorial &&
        map.getCurrentRoom().id == 2) {
      Tutorial tutorial = map.getCurrentRoom() as Tutorial;
      output += tutorial.steps[3];
    }

    if (player.health <= 0) {
      _controller.gameOver();
    }
    printscrn(output);
  }

  String processVerb(List<WordAndType> wordAndType) {
    developer.log("Processing verb");
    WordAndType verb = wordAndType[0];
    switch (verb.word) {
      case "stop":
        return "Pulse stopped";
      case "lightmode":
        _controller.theme.toggleTheme(false);
        return "Light mode activated";
      case "darkmode":
        _controller.theme.toggleTheme(true);
        return "Dark mode activated";
      case "crouch":
        player.crouched = true;
        String output = "You crouch down";
        //if room is room number 1, printscrn("You see a mirror below the bed. It looks like there is another world through it.");
        if (map.getCurrentRoom().id == 20) {
          output +=
              "\nYou see a mirror below the bed. It looks like there is another world through it.";
        }
        return output;
      case "stand":
        player.crouched = false;
        return "You stand up";
      case "i":
      case "inv":
      case "inventory":
        if (map.currentRoom is Tutorial) {
          Tutorial tutorial = map.currentRoom as Tutorial;
          if (tutorial.id == 0) {
            return "${player.printInventory()}\n${tutorial.steps[2]}";
          }
        }
        return player.printInventory();
      case "describe":
      case "look":
        //needs modifying.
        //if room is number 1 return
        if (map.currentRoom is Tutorial) {
          Tutorial tutorial = map.currentRoom as Tutorial;
          if (tutorial.id == 1) {
            //check if item is an enemy
            //if it is, discovery = true
            //if it isn't, return room description
            Item? beast = map.getCurrentRoom().getItem("beast");
            if (beast != null && beast is Enemy) {
              beast.discovered = true;
              developer.log("beast discovered");
            }
            return "${tutorial.steps[1]}";
          }
        }
        return map.getCurrentRoom().description;
      case "north":
      case "n":
        //need to add this logic to the move function to reduce repetitiveness
        if (map.currentRoom is Tutorial) {
          Tutorial tutorial = map.currentRoom as Tutorial;
          if (tutorial.id == 0) {
            String output = map.move("north");
            Tutorial tutorial = map.currentRoom as Tutorial;
            return "$output\n${tutorial.steps[0]}";
          }
        }
        return map.move("north");
      case "northeast":
      case "ne":
        return map.move("northeast");
      case "northwest":
      case "nw":
        return map.move("northwest");
      case "south":
      case "s":
        return map.move("south");
      case "southwest":
      case "sw":
        return map.move("southwest");
      case "southeast":
      case "se":
        return map.move("southeast");
      case "west":
      case "w":
        return map.move("west");
      case "east":
      case "e":
        if (map.currentRoom is Tutorial) {
          Tutorial tutorial = map.currentRoom as Tutorial;
          if (tutorial.id == 1) {
            String output = map.move("east");
            Tutorial tutorial = map.currentRoom as Tutorial;
            return "$output\n${tutorial.steps[0]}";
          }
        }
        return map.move("east");
      case "climb":
      case "up":
      case "u":
        return map.move("up");
      case "down":
      case "d":
        return map.move("down");
      case "run":
        developer.log("running.");
        List<int> exits = map.getCurrentRoom().getExits();
        List<String> directions = [
          "north",
          "northeast",
          "east",
          "southeast",
          "south",
          "southwest",
          "west",
          "northwest",
          "up",
          "down"
        ];
        Random random = Random();
        int index = random.nextInt(exits.length);
        while (exits[index] == -1) {
          index = random.nextInt(exits.length);
        }
        return map.move(directions[index]);
      default:
        return "Sorry I can't ${verb.word}";
    }
  }

  String processVerbNoun(List<WordAndType> wordAndType) {
    if (wordAndType.length < 2) {
      return "Invalid command. Please provide both a verb and a noun.";
    }

    developer.log("Processing verb and noun");
    WordAndType verb = wordAndType[0];
    WordAndType noun = wordAndType[1];

    switch (verb.word) {
      case "read":
        for (Item item in player.inventory.items) {
          if (item.isSynonym(noun.word)) {
            if (item is Book) {
              return item.read();
            } else {
              return "You can't read a ${item.name}.";
            }
          }
        }
        return "You don't have a ${noun.word}.";
      case "take":
        String output = map.takeItem(noun.word, player);
        if (map.currentRoom is Tutorial) {
          Tutorial tutorial = map.currentRoom as Tutorial;
          if (tutorial.id == 0 && noun.word == "sword") {
            output += tutorial.steps[1];
          } else if (tutorial.id == 2 &&
              player.inventory.inInventory("bread") != null &&
              player.inventory.inInventory("gourde") != null) {
            output += tutorial.steps[2];
          }
        }
        return output;
      case "drop":
        Item? item = player.inventory.removeItem(noun.word);
        if (item != null) {
          map.getCurrentRoom().addItem(item);
          return "You drop the ${item.name}.";
        }
        return "You don't have a ${noun.word}.";
      case "open":
      case "close":
        bool isOpenAction = (verb.word == "open");
        if (map.getCurrentRoom() is InteractableRoom) {
          return interactDoor(noun, flag: isOpenAction);
        }
        Room currentRoom = map.getCurrentRoom();
        String output = interactContainer(noun, flag: isOpenAction);
        if (currentRoom is Tutorial) {
          // ignore: unnecessary_cast
          Tutorial tutorial = currentRoom as Tutorial;
          if (tutorial.id == 2 && noun.word == "cabinet") {
            output += "\n${tutorial.steps[1]}";
          }
        }
        return output;
      case "unlock":
        return "You unlock the ${noun.word}.";
      case "examine":
        return "You examine the ${noun.word}.";
      case "use":
        return "You use the ${noun.word}.";
      case "go":
      case "move":
      case "walk":
        return "You go to the ${noun.word}.";
      case "inspect":
        return "You inspect the ${noun.word}.";
      case "eat":
      case "drink":
        return player.eat(noun.word);
      case "climb":
        return _processClimb(noun);
      default:
        return "Sorry, I don't know how to '${verb.word}' a '${noun.word}'.";
    }
  }

  String _processClimb(WordAndType noun) {
    const directions = [
      "north",
      "northeast",
      "east",
      "southeast",
      "south",
      "southwest",
      "west",
      "northwest",
      "up",
      "down"
    ];

    var currentRoom = map.getCurrentRoom();
    if (currentRoom is InteractableRoom) {
      for (int i = 0; i < currentRoom.interactables.length; i++) {
        if (currentRoom.interactables[i] != -1) {
          var door = map.floatingItems[currentRoom.interactables[i]];
          if (door.isSynonym(noun.word)) {
            return map.move(directions[i]);
          }
        }
      }
    }
    return "You don't see a door to climb.";
  }

  String interactContainer(WordAndType noun, {bool flag = true}) {
    Item? item = map.getCurrentRoom().getItem(noun.word);
    if (item != null && item is Container) {
      if (flag) {
        return item.open();
      } else {
        return item.close();
      }
    } else {
      return "You don't see a ${noun.word} to open";
    }
  }

  String interactDoor(WordAndType noun, {bool flag = true}) {
    InteractableRoom room = map.getCurrentRoom() as InteractableRoom;
    for (int interactable in room.interactables) {
      if (interactable != -1) {
        //get interactable and check name
        var door = map.floatingItems[interactable];
        //check if door is Locked door or Door
        String type = door.runtimeType.toString();
        //
        switch (type) {
          case 'Door':
            Door thing = door as Door;
            return thing.interact(flag);
          case 'LockedDoor':
            LockedDoor thing = door as LockedDoor;
            return thing.interact(flag);
          case 'Trapdoor':
            Trapdoor thing = door as Trapdoor;
            return thing.interact(flag);
          default:
            developer.log("runtime type: $type");
            break;
        }
      }
    }
    return "You don't see a door to open";
  }

  String processVerbVerb(List<WordAndType> wordAndType) {
    WordAndType verb1 = wordAndType[0];
    WordAndType verb2 = wordAndType[1];

    switch (verb1.word) {
      case "go":
      case "move":
      case "run":
        switch (verb2.word) {
          case "north":
          case "n":
            if (map.currentRoom is Tutorial) {
              Tutorial tutorial = map.currentRoom as Tutorial;
              if (tutorial.id == 0) {
                String output = map.move("north");
                Tutorial tutorial = map.currentRoom as Tutorial;
                return "$output\n${tutorial.steps[0]}";
              }
            }
            developer.log("moving north");
            return map.move("north");
          case "northeast":
          case "ne":
            return map.move("northeast");
          case "northwest":
          case "nw":
            return map.move("northwest");
          case "south":
          case "s":
            return map.move("south");
          case "southwest":
          case "sw":
            return map.move("southwest");
          case "southeast":
          case "se":
            return map.move("southeast");
          case "west":
          case "w":
            return map.move("west");
          case "east":
          case "e":
            if (map.currentRoom is Tutorial) {
              Tutorial tutorial = map.currentRoom as Tutorial;
              if (tutorial.id == 1) {
                String output = map.move("east");
                Tutorial tutorial = map.currentRoom as Tutorial;
                return "$output\n${tutorial.steps[0]}";
              }
            }
            return map.move("east");
          case "climb":
          case "up":
          case "u":
            return map.move("up");
          case "down":
          case "d":
            return map.move("down");
          default:
            return "Sorry I don't know how to ${verb1.word} ${verb2.word}";
        }
      default:
        return "Sorry I don't know how to ${verb1.word} ${verb2.word}";
    }
  }

  String processVerbVerbVerb(List<WordAndType> wordAndType) {
    return "Processing verb and verbreturn";
  }

  String processVerbPrepositionNoun(List<WordAndType> wordAndType) {
    developer.log("Processing verb preposition noun");
    WordAndType verb = wordAndType[0];
    WordAndType preposition = wordAndType[1];
    WordAndType noun = wordAndType[2];
    switch (verb.word) {
      case "crawl":
        if (preposition.word == "through" || preposition.word == "into") {
          if (noun.word == "mirror") {
            if (!player.crouched) {
              return "You don't see a mirror to crawl through";
            }
            String output = "You crawl through the mirror\n";
            if (map.getCurrentRoom().id == 20) {
              map.setRoom(21);
              return output += map.getCurrentRoom().describe();
            } else {
              return "You can't crawl through that";
            }
          } else {
            return "You can't crawl through that";
          }
        } else {
          return "You can't crawl ${preposition.word} that";
        }
      case "climb":
        String output = "";
        //look in the room for a door with synonym noun
        //if it exists, climb it
        //if it doesn't, return "You can't climb that"
        //if it does, return "You climb the door"
        var currentRoom = map.getCurrentRoom();
        if (currentRoom is InteractableRoom) {
          for (int interactable in currentRoom.interactables) {
            if (interactable != -1) {
              var door = map.floatingItems[interactable];
              if (door.isSynonym(noun.word) && door is Door) {
                List<int> rooms = door.getRooms();
                if (rooms[0] == currentRoom.id) {
                  map.setRoom(rooms[1]);
                  output += "You climb the ${noun.word}\n";
                  return output += map.getCurrentRoom().describe();
                } else if (rooms[1] == currentRoom.id) {
                  map.setRoom(rooms[0]);
                  output += "You climb the ${noun.word}\n";
                  return output += map.getCurrentRoom().describe();
                }
              }
            }
          }
        }
        return "You can't climb that";
      default:
        return "Sorry, I don't know how to '${verb.word}' '${preposition.word}' '${noun.word}'.";
    }
  }

  String processVerbNounPrepositionNoun(List<WordAndType> wordAndType) {
    if (wordAndType.length < 4) {
      return "That command is too short!";
    }
    //print("Processing verb noun preposition noun");
    //open door with key
    WordAndType verb = wordAndType[0];
    WordAndType noun1 = wordAndType[1];
    WordAndType noun2 = wordAndType[3];
    switch (verb.word) {
      case "unlock":
      case "open":
        //find noun1 in room
        //find noun2 in inventory
        //if both exist, check if noun1 is a locked door
        //if it is, use noun2 to open noun1

        if (map.getCurrentRoom() is InteractableRoom) {
          for (int interactable
              in (map.getCurrentRoom() as InteractableRoom).interactables) {
            if (interactable != -1) {
              //get interactable and check name
              var door = map.floatingItems[interactable];
              //check if door is Locked door or Door
              String type = door.runtimeType.toString();
              switch (type) {
                case 'LockedDoor':
                  LockedDoor thing = door as LockedDoor;
                  int keyid = thing.requiredKey;
                  Item? key = player.inventory.getItem(noun2.word);
                  if (key != null && key.id == keyid) {
                    player.inventory.removeItem(noun2.word);
                    return thing.unlock(keyid);
                  } else {
                    return "You don't have the correct key";
                  }
                default:
                  // no printscrn because in loop
                  developer.log("No door.");
                  break;
              }
            }
          }
          return "You don't see a $noun2 to open";
        } else {
          return "You don't see a $noun2 to open";
        }
      case "cut":
        //check if noun1 is a beast synonym and noun2 is a sword synonym and is in inventory
        //check if beast is in room. and is synonym
        //check if sword is in inventory and is synonym
        //if all true, cut beast with sword
        var beast = map.getCurrentRoom().getItem(noun1.word);
        var sword = player.inventory.inInventory(noun2.word);
        if (beast == null) {
          return "You don't see a ${noun1.word} to cut";
        }
        if (sword == null) {
          return "You don't have a ${noun2.word} to cut with";
        }
        if (beast is Enemy && sword is Weapon) {
          String output = beast.takeDamage(sword.damage);
          if (beast.health <= 0 && map.getCurrentRoom() is Tutorial) {
            Tutorial tutorial = map.getCurrentRoom() as Tutorial;
            output += tutorial.steps[2];
          }
          return output;
        }
        return "You can't cut ${noun1.word} with ${noun2.word}";

      default:
        return "Sorry I don't know how to ${verb.word} ${noun1.word} ${noun2.word}";
    }
  }
}
