import 'package:firebase_database/firebase_database.dart';
import 'dart:developer' as developer;
import 'room.dart';
// ignore: unused_import
import 'package:timeless_echo/notifier.dart';
import 'item.dart';
import 'interactibles.dart';
import 'player.dart';

class Atlas {
  Map<int, Room> _rooms = {};
  //items that get referenced in multiple areas.
  Map<int, dynamic> floatingItems = {};
  int _currentRoom = 0;

  get currentRoom => _rooms[_currentRoom];

  Room getCurrentRoom() {
    return _rooms[_currentRoom]!;
  }

  Future<Map<int, Room>> loadRooms(Map<int, dynamic> objects) async {
    developer.log('Loading rooms...');
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('rooms');
    Map<int, Room> loadedRooms = {};
    // ignore: prefer_typing_uninitialized_variables
    var data;

    try {
      final snapshot = await dbRef.get();
      data = snapshot.value;
    } catch (e) {
      developer.log('Error loading rooms from Firebase: $e', level: 1);
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
          developer.log('Loading interactable room');
          InteractableRoom room =
              InteractableRoom.withExits(i, name, description, exits);
          if (roomdata.containsKey('interactables')) {
            List<dynamic> interactables = roomdata['interactables'];
            room.interactables = interactables;
          }
          developer.log('Loaded interactable room');
          loadedRooms[room.id] = room;
          break;
        case 'tutorial room':
          List<String> steps = roomdata['instructions'].cast<String>();
          Tutorial room =
              Tutorial.withSteps(i, name, description, exits, steps);
          loadedRooms[room.id] = room;
          break;
        default:
          developer.log('Invalid room type');
      }

      if (roomdata.containsKey('objects')) {
        //gets all item IDs in the room
        List<int> itemids = roomdata['objects'].cast<int>();
        print("objects: $objects");
        print(itemids);
        for (var itemid in itemids) {
          if (objects.containsKey(itemid)) {
            loadedRooms[i]!.addItem(objects[itemid]);
            developer.log('Added ${objects[itemid].name} to room $i');
          } else {
            developer.log('Item $itemid not found');
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
    developer.log('Loading items...');
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('objects');
    // Using a dynamic map because the items might have different types
    Map<int, dynamic> loadedItems = {};

    // ignore: prefer_typing_uninitialized_variables
    var data;

    try {
      final snapshot = await dbRef.get();
      data = snapshot.value;
      developer.log('Raw data from Firebase: $data');
    } catch (e) {
      developer.log('Error loading items from Firebase: $e');
      return loadedItems; // Return an empty map if an error occurs
    }

    if (data == null) {
      developer.log("Data is null");
      return loadedItems; // Return early if no data is found
    }

    developer.log("Data is not null");
    developer.log("Data runtimeType: ${data.runtimeType}");
    //required because data format can change in firebase and break everything
    //yes it's stupid
    if (data is Map) {
      for (var entry in data.entries) {
        var key = int.tryParse(entry.key.toString());
        var itemData = entry.value;
        await loadEntry(itemData, key!, loadedItems, floatingItems);
      }
    } else if (data is List) {
      for (var i = 0; i < data.length; i++) {
        var itemData = data[i];
        await loadEntry(itemData, i, loadedItems, floatingItems);
      }
    } else {
      throw Exception("Data is not a map or list");
    }

    return loadedItems;
  }

  Future<void> loadEntry(
      dynamic entry, int key, Map loaded, Map floating) async {
    //convert entry to dictionary
    Map itemData = entry as Map;
    developer.log("${itemData}");
    dynamic item = await createItem(itemData, key);
    if (item != null) {
      if (itemData.containsKey('synonyms')) {
        List<String> synonyms = itemData['synonyms'].cast<String>();
        item.addSynonyms(synonyms);
      }

      if (item is Door || item.runtimeType == Door) {
        LockedDoor door = item as LockedDoor;
        developer.log("Adding door to floating items");
        floatingItems[key] = door;
        developer.log("Floating items: $floatingItems");
      } else {
        loaded[key] = item;
      }
    }
  }

  Future<dynamic> createItem(Map itemData, int id) async {
    developer.log('Creating item...');
    String itemType = itemData['type'];
    developer.log(itemType);

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
        developer.log('Creating container...');
        String name = itemData['name'];
        String description = itemData['description'];
        Container container = Container(id, name, description);

        if (itemData.containsKey('objects')) {
          developer.log("getting objects");
          List<dynamic> childItemsData = itemData['objects'];
          developer.log("gotten objects");
          for (var childData in childItemsData) {
            developer.log("${childData}");
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
          developer.log('No objects in container');
        }

        if (itemData.containsKey('takeable')) {
          container.setTakeable(itemData['takeable'] as bool);
        }
        return container;

      case 'locked door':
        developer.log('Creating locked door...');
        // Handle locked door creation here
        String name = itemData['name'];
        int room1 = itemData['rooms'][0];
        int room2 = itemData['rooms'][1];
        int keyid = itemData['key'];
        LockedDoor door = LockedDoor(keyid, name, room1, room2);
        developer.log("${door.runtimeType}");
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
    developer.log("${_rooms[_currentRoom]!.getExits()}");
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
        developer.log("${room.interactables}");
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
    developer.log('Taking item $word');
    Room room = getRoom(_currentRoom);
    developer.log("${room.items}");
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