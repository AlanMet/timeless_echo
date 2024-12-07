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
  //items that get referenced in multiple areas.
  Map<int, dynamic> floatingItems = {};
  int _currentRoom = 7;

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
        case 'interactable room':
          print('Loading interactable room');
          InteractableRoom room =
              InteractableRoom.withExits(i, name, description, exits);
          if (roomdata.containsKey('interactables')) {
            List<dynamic> interactables = roomdata['interactables'];
            room.interactables = interactables;
          }
          print('Loaded interactable room');
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
          } else {
            print('Item $itemid not found');
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
      if (data[i] != null) {
        var itemData = data[i];
        //only loading type at this stage bnecause storage isn't consistent
        //(firebase removes empty entries so consistency is not possible)
        dynamic item = await createItem(itemData, i);
        if (item != null) {
          if (itemData.containsKey('synonyms')) {
            List<String> synonyms = itemData['synonyms'].cast<String>();
            item.addSynonyms(synonyms); // Add synonyms after item creation
          }
          if (item is Door || item.runtimeType == Door) {
            LockedDoor door = item;
            print("Adding door to floating items");
            floatingItems[i] = door;
            print(floatingItems);
          } else {
            loadedItems[i] = item;
          }
        }
        print("Done.");
      }
    }
    print("Done.");

    return loadedItems;
  }

  Future<dynamic> createItem(Map itemData, int id) async {
    print('Creating item...');
    String itemType = itemData['type'];
    print(itemType);

    switch (itemType) {
      case 'item':
        String name = itemData['name'];
        String description = itemData['description'];
        Item item = Item(id, name, description);
        return item;

      case 'weapon':
        String name = itemData['name'];
        String description = itemData['description'];
        int damage = itemData['damage'];
        Weapon weapon = Weapon(id, name, description, damage);
        return weapon;

      case 'container':
        print('Creating container...');
        String name = itemData['name'];
        String description = itemData['description'];
        Container container = Container(id, name, description);

        if (itemData.containsKey('objects')) {
          List<dynamic> childItemsData = itemData['objects'];

          for (var childData in childItemsData) {
            print(childData);
            dynamic childItem =
                await createItem(childData, id); // Recursive call

            if (childData.containsKey('synonyms')) {
              List<String> synonyms = childData['synonyms'].cast<String>();
              childItem
                  .addSynonyms(synonyms); // Add synonyms after item creation
            }

            container.addItem(childItem);
          }
        } else {
          print('No objects in container');
        }
        return container;

      case 'locked door':
        print('Creating locked door...');
        // Handle locked door creation here
        String name = itemData['name'];
        int room1 = itemData['rooms'][0];
        int room2 = itemData['rooms'][1];
        int keyid = itemData['key'];
        LockedDoor door = LockedDoor(keyid, name, room1, room2);
        print(door.runtimeType);
        return door;
      case 'interactable':
        break;
      case 'food':
        String name = itemData['name'];
        String description = itemData['description'];
        int health = itemData['health'];
        Food food = Food(id, name, description, health);
        return food;
      case 'drink':
        String name = itemData['name'];
        String description = itemData['description'];
        int health = itemData['health'];
        Drink drink = Drink(id, name, description, health);
        return drink;
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
    int directionIndex = -1;
    //all roomtypes have exits
    if (directions.containsKey(direction)) {
      directionIndex = directions[direction]!;
      int newindex = _rooms[_currentRoom]!.getExits()[directionIndex];
      newIndex = newindex;
    } else {
      return 'Invalid direction';
    }

    if (newIndex != -1) {
      // if exit
      _currentRoom = newIndex;
      Room room = getRoom(_currentRoom);
      return room.describe();
    } else {
      // if no exit
      Room currentRoom = getRoom(_currentRoom);
      if (currentRoom is InteractableRoom) {
        InteractableRoom room = currentRoom;
        print(room.interactables);
        if (room.interactables[directionIndex] != null) {
          int interactableID = room.interactables[directionIndex];
          if (floatingItems[interactableID] is Door) {
            LockedDoor door = floatingItems[interactableID];
            if (door.isOpen) {
              _currentRoom = door.getRooms()[1];
              Room room = getRoom(_currentRoom);
              return room.describe();
            } else {
              return 'The ${door.name} is closed';
            }
          }
          return "found";
        } else {
          return 'You cannot go that way';
        }
      } else {
        return 'You cannot go that way';
      }
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
      // if (item is List<Item>) {
      //   String output = '';
      //   for (var i in item) {
      //     if (player.inventory.addItem(i)) {
      //       output += 'You took the ${i.name}';
      //     } else {
      //       output += 'You cannot carry any more items';
      //     }
      //   }
      //   return output;
      // }
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