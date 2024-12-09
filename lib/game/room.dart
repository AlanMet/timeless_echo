import 'interactibles.dart';
import 'item.dart';
import 'helpers.dart';

class Room {
  late int _id;
  late final String _name;
  late final String _description;
  late List<Item> _items;
  late List<int> _exits;

  int get id => _id;
  String get name => _name;
  String get description => _description;
  List<Item> get items => _items;

  Room(this._id, this._name, this._description) {
    _items = [];
    _exits = [-1, -1, -1, -1, -1, -1, -1, -1];
  }

  Room.withExits(this._id, this._name, this._description, List<int> exits) {
    _items = [];
    if (exits.length == 10) {
      _exits = exits;
    } else {
      _exits = [-1, -1, -1, -1, -1, -1, -1, -1];
    }
  }

  void addExit(int room, Direction direction) {
    // add exits based on index
    switch (direction) {
      case Direction.north:
        _exits[0] = room;
        break;
      case Direction.east:
        _exits[1] = room;
        break;
      case Direction.south:
        _exits[2] = room;
        break;
      case Direction.west:
        _exits[3] = room;
        break;
      case Direction.northEast:
        _exits[4] = room;
        break;
      case Direction.northWest:
        _exits[5] = room;
        break;
      case Direction.southEast:
        _exits[6] = room;
        break;
      case Direction.southWest:
        _exits[7] = room;
        break;
      case Direction.up:
        _exits[8] = room;
        break;
      case Direction.down:
        _exits[9] = room;
        break;
    }
  }

  void addItems(List<Item> items) {
    _items.addAll(items);
  }

  void addItem(Item item) {
    _items.add(item);
  }

  String describe() {
    String output = "$_name\n$_description\n";
    if (_items.isNotEmpty) {
      output += "The room contains: ";
      for (var item in _items) {
        output += item.name + ", ";
      }
    }
    return output;
  }

  dynamic removeItem(String itemName) {
    if (itemName == "all") {
      return takeAll();
    }
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isSynonym(itemName)) {
        print("found item");
        return _items.removeAt(i);
      }
      if (_items[i] is Container) {
        Container container = _items[i] as Container;
        if (container.isOpen()) {
          Item? item = container.removeItemByName(itemName);
          if (item != null) {
            return item;
          }
        } else {
          return "The ${container.name} is closed.";
        }
      }
    }
  }

  bool inRoom(String itemName) {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isSynonym(itemName)) {
        return true;
      }
    }
    return false;
  }

  Item? getItem(String itemName) {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isSynonym(itemName)) {
        return _items[i];
      }
    }
    return null;
  }

  List<Item> takeAll() {
    var temp = _items;
    _items = [];
    return temp;
  }

  List<int> getExits() {
    return _exits;
  }

  int? getRoomID() {
    return _id;
  }
}

class InteractableRoom extends Room {
  List<dynamic> interactables = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1];

  InteractableRoom(super.id, super.name, super.description);

  InteractableRoom.withExits(
      int id, String name, String description, List<int> exits)
      : super.withExits(id, name, description, exits);
}

class Tutorial extends Room {
  late List<String> _steps;

  Tutorial(super.id, super.name, super.description) {
    _steps = [];
  }

  get steps => _steps;

  Tutorial.withSteps(int id, String name, String description, List<int> exits,
      List<String> steps)
      : super.withExits(id, name, description, exits) {
    _steps = steps;
  }

  Tutorial.withExits(int id, String name, String description, List<int> exits)
      : super.withExits(id, name, description, exits);

  @override
  String describe() {
    return "$_name\n$_description\n";
  }
}
