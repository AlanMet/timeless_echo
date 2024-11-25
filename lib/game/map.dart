import 'package:firebase_database/firebase_database.dart';

import 'room.dart';
import 'dart:io';
import 'package:timeless_echo/notifier.dart';
import 'dart:convert';
import 'item.dart';
import 'helpers.dart';
import 'interactibles.dart';
import 'player.dart';

class Atlas {
  Map<int, Room> _rooms = {};
  int _currentRoom = 0;

  get currentRoom => _rooms[_currentRoom];

  Room getCurrentRoom() {
    return _rooms[_currentRoom]!;
  }

  Future<Map<int, Room>> loadRooms(Map<int, dynamic> objects) async {
    print('Loading rooms...');
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('rooms');
    Map<int, Room> loadedRooms = {};
    var data;

    try {
      final snapshot = await dbRef.get();
      data = snapshot.value;
    } catch (e) {
      print('Error loading rooms from Firebase: $e');
    }

    for (var i = 0; i < data.length; i++) {
      var roomdata = data[i];
      //print(roomdata);
      String roomtype = roomdata['type'];
      String name = roomdata['name'];
      String description = roomdata['description'];
      List<int> exits = roomdata['exits'].cast<int>();
      switch (roomtype) {
        case 'room':
          Room room = Room.withExits(i, name, description, exits);
          loadedRooms[room.id] = room;
          break;
        case 'interactable':
          InteractableRoom room =
              InteractableRoom.withExits(i, name, description, exits);
          loadedRooms[room.id] = room;
          break;
        case 'tutorial room':
          Tutorial room = Tutorial.withExits(i, name, description, exits);
          loadedRooms[room.id] = room;
          break;
        default:
          print('Invalid room type');
      }

      if (roomdata.containsKey('objects')) {
        //gets all item IDs in the room
        List<int> itemids = roomdata['objects'].cast<int>();
        for (var itemid in itemids) {
          if (objects.containsKey(itemid)) {
            loadedRooms[i]!.addItem(objects[itemid]);
            print('Added ${objects[itemid].name} to room $i');
          }
        }
      }
    }
    _rooms = loadedRooms;
    return _rooms;
  }

  Future<Map<int, dynamic>> loadItems() async {
    print('Loading items...');
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('objects');
    //dynamic because while item is the superclass, interactables are also loaded here.
    Map<int, dynamic> loadedItems = {};

    var data;

    try {
      final snapshot = await dbRef.get();
      data = snapshot.value;
      print(data);
    } catch (e) {
      print('Error loading rooms from Firebase: $e');
    }

    for (var i = 0; i < data.length; i++) {
      print("Loading item $i/${data.length}");
      var itemData = data[i];
      //only loading type at this stage bnecause storage isn't consistent
      //(firebase removes empty entries so consistency is not possible)
      dynamic item = await createItem(itemData);
      if (item != null) {
        if (itemData.containsKey('synonyms')) {
          List<String> synonyms = itemData['synonyms'].cast<String>();
          item.addSynonyms(synonyms); // Add synonyms after item creation
        }
        loadedItems[i] = item;
      }
      print("Done.");
    }
    print("Done.");

    return loadedItems;
  }

  Future<dynamic> createItem(Map itemData) async {
    print('Creating item...');
    String itemType = itemData['type'];
    print(itemType);

    switch (itemType) {
      case 'item':
        String name = itemData['name'];
        String description = itemData['description'];
        Item item = Item(name, description);
        return item;

      case 'weapon':
        String name = itemData['name'];
        String description = itemData['description'];
        int damage = itemData['damage'];
        Weapon weapon = Weapon(name, description, damage);
        return weapon;

      case 'container':
        String name = itemData['name'];
        String description = itemData['description'];
        Container container = Container(name, description);

        if (itemData.containsKey('objects')) {
          List<dynamic> childItemsData = itemData['objects'];
          for (var childData in childItemsData) {
            dynamic childItem = await createItem(childData); // Recursive call
            container.addItem(childItem);
          }
        }
        return container;

      case 'locked door':
        // Handle locked door creation here
        print('Loading locked door');
        // Return a LockedDoor instance, if applicable
        break;

      case 'interactable':
        break;
      case 'enemy':
        break;

      default:
        throw Exception('Invalid item type: $itemType');
    }
  }

  String move(String direction) {
    print(_rooms[_currentRoom]!.getExits());
    Map<String, int> directions = {
      'north': 0,
      'northeast': 1,
      'east': 2,
      'southeast': 3,
      'south': 4,
      'southwest': 5,
      'west': 6,
      'northwest': 7,
      'up': 8,
      'down': 9,
    };

    int newIndex = -1;

    if (directions.containsKey(direction)) {
      int directionIndex = directions[direction]!;
      int newindex = _rooms[_currentRoom]!.getExits()[directionIndex];
      newIndex = newindex;
    } else {
      return 'Invalid direction';
    }

    if (newIndex == -1) {
      return 'You cannot go that way';
    } else {
      _currentRoom = newIndex;
      Room room = getRoom(_currentRoom);
      return "${room.name}\n${room.description}";
    }
  }

  Room getRoom(int roomid) {
    return _rooms[roomid]!;
  }

  takeItem(String word, Player player) {
    Room room = getRoom(_currentRoom);
    dynamic item = room.removeItem(word);
    if (item != null) {
      if (item is Item) {
        if (player.inventory.addItem(item)) {
          return 'You took the ${item.name}';
        } else {
          return 'You cannot carry any more items';
        }
      }
      if (item is List<Item>) {
        String output = '';
        for (var i in item) {
          if (player.inventory.addItem(i)) {
            output += 'You took the ${i.name}';
          } else {
            output += 'You cannot carry any more items';
          }
        }
        return output;
      }
    } else {
      return 'There is no $word here';
    }
  }
}


// String move(String direction) {
//     print(_rooms[_currentRoom]!.getExits());
//     Map<String, int> directions = {
//       'north': 0,
//       'northeast': 1,
//       'east': 2,
//       'southeast': 3,
//       'south': 4,
//       'southwest': 5,
//       'west': 6,
//       'northwest': 7,
//     };
//     int newIndex = -1;
//     if (directions.containsKey(direction)) {
//       int directionIndex = directions[direction]!;
//       int newindex = _rooms[_currentRoom]!.getExits()[directionIndex];
//       newindex;
//     } else {
//       return 'Invalid direction';
//     }
//     if (newIndex == -1) {
//       return 'You cannot go that way';
//     } else {
//       _currentRoom = newIndex;
//       Room room = getRoom(_currentRoom);
//       return "${room.name}\n${room.description}";
//     }
//   }