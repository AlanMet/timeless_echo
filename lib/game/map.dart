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
      //print(roomdata);
      String roomtype = roomdata['type'];
      String name = roomdata['name'];
      String description = roomdata['description'];
      List<int> exits = roomdata['exits'].cast<int>();

      switch (roomtype) {
        case 'room':
          print('room');
          Room room = Room.withExits(i, name, description, exits);
          loadedRooms[room.id] = room;
          print("done.");
          break;
        case 'interactable':
          print('interactable');
          InteractableRoom room =
              InteractableRoom.withExits(i, name, description, exits);
          loadedRooms[room.id] = room;
          print("done.");
          break;
        case 'tutorial room':
          print('tutorial room');
          Tutorial room = Tutorial.withExits(i, name, description, exits);
          loadedRooms[room.id] = room;
          print("done.");
          break;
        default:
          print('Invalid room type');
      }
      print("Room $i/${data.length} loaded");
    }
    _rooms = loadedRooms;
    print('Rooms loaded');
    return _rooms;
  }

  List<Item> loadItems() {
    return [];
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