import 'package:firebase_database/firebase_database.dart';

import 'room.dart';
import 'dart:io';
import 'package:timeless_echo/notifier.dart';
import 'dart:convert';
import 'item.dart';
import 'helpers.dart';

class Atlas {
  Map<int, Room> _rooms = {};
  int _currentRoom = 0;

  get currentRoom => _rooms[_currentRoom];

  Room getCurrentRoom() {
    return _rooms[_currentRoom]!;
  }

  Future<Map<int, Room>> loadRooms() async {
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
        case 'tutorial':
          Tutorial room = Tutorial.withExits(i, name, description, exits);
          loadedRooms[room.id] = room;
          break;
        default:
          print('Invalid room type');
      }
    }
    _rooms = loadedRooms;
    return _rooms;
  }

  Future<Map<String, Item>> loadItems() async {
    print('Loading items...');
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('objects');
    Map<String, Item> loadedItems = {};

    var data;

    try {
      final snapshot = await dbRef.get();
      data = snapshot.value;
      print(data);
    } catch (e) {
      print('Error loading rooms from Firebase: $e');
    }

    for (var i = 0; i < data.length; i++) {
      var itemData = data[i];
      print(itemData);
      String roomtype = itemData['type'];
      String name = itemData['name'];
      String description = itemData['description'];
      print(itemData['synonyms']);
      List<String> synonyms = itemData['synonyms'].cast<String>();
      print('Synonyms: $synonyms');

      switch (roomtype) {
        case 'item':
          Item item = Item(name, description, synonyms);
          loadedItems[item.name] = item;
          print('Item loaded: ${item.name}');
          break;
        default:
          print('Invalid item type');
      }
    }

    return loadedItems;
  }

  void fillRooms(List<Item> items) {}

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