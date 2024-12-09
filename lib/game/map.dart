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
  int _currentRoom = 4;

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
          List<String> steps = roomdata['instructions'].cast<String>();
          Tutorial room =
              Tutorial.withSteps(i, name, description, exits, steps);
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

  void setRoom(int roomid) {
    _currentRoom = roomid;
  }

  Future<Map<int, dynamic>> loadItems() async {
    print('Loading items...');
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('objects');
    // Using a dynamic map because the items might have different types
    Map<int, dynamic> loadedItems = {};

    var data;

    try {
      final snapshot = await dbRef.get();
      data = snapshot.value;
      print('Raw data from Firebase: $data');
    } catch (e) {
      print('Error loading items from Firebase: $e');
      return loadedItems; // Return an empty map if an error occurs
    }

    if (data == null) {
      print("Data is null");
      return loadedItems; // Return early if no data is found
    }

    print("Data is not null");
    print("Data runtimeType: ${data.runtimeType}");

    // Ensure the data is a Map
    if (data is Map) {
      for (var entry in data.entries) {
        var key = int.tryParse(
            entry.key.toString()); // Convert key to int if possible
        var itemData = entry.value;
        if (key == null) {
          print("Key is null");
          continue;
        }

        print("Processing item with key: $key");
        if (itemData != null) {
          print("Item data: $itemData");

          // Create the item using the provided item data
          dynamic item = await createItem(itemData, key);
          if (item != null) {
            // Add synonyms if present
            if (itemData.containsKey('synonyms')) {
              List<String> synonyms = itemData['synonyms'].cast<String>();
              item.addSynonyms(synonyms);
            }

            // Handle doors separately
            if (item is Door || item.runtimeType == Door) {
              LockedDoor door = item as LockedDoor;
              print("Adding door to floating items");
              floatingItems[key] = door;
              print("Floating items: $floatingItems");
            } else {
              loadedItems[key] = item;
            }
          }
          print("Item processing done for key: $key");
        } else {
          print("Item with key $key is null");
        }
      }
    } else {
      print("Data is not a Map");
    }

    print("All items loaded: $loadedItems");
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

        if (itemData.containsKey('takeable')) {
          container.setTakeable(itemData['takeable'] as bool);
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
      case 'book':
        String name = itemData['name'];
        String description = itemData['description'];
        String content = itemData['contents'];
        Book book = Book(id, name, description, content);
        return book;
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
        String name = itemData['name'];
        String description = itemData['description'];
        int health = itemData['health'];
        int damage = itemData['damage'];
        Enemy enemy = Enemy(id, name, description, health, damage);
        if (itemData.containsKey('synonyms')) {
          List<String> synonyms = itemData['synonyms'].cast<String>();
          enemy.addSynonyms(synonyms);
        }

        if (itemData.containsKey('takeable')) {
          enemy.setTakeable(itemData['takeable'] as bool);
        }
        return enemy;
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

  dynamic inRoom(String word) {
    Room room = getRoom(_currentRoom);
    if (room.items.isNotEmpty) {
      for (var item in room.items) {
        if (item.isSynonym(word)) {
          return item;
        }
      }
    }
    return null;
  }

  Item? getItem(String word) {
    Room room = getRoom(_currentRoom);
    if (room.items.isNotEmpty) {
      for (var item in room.items) {
        if (item.isSynonym(word)) {
          return item;
        }
      }
    }
    return null;
  }

  takeItem(String word, Player player) {
    print('Taking item $word');
    Room room = getRoom(_currentRoom);
    print(room.items);
    dynamic item = room.removeItem(word);
    if (item is String) {
      return item;
    }
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