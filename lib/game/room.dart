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

  List<int> getExits() {
    return _exits;
  }

  int? getRoomID() {
    return _id;
  }
}

class InteractableRoom extends Room {
  final List<IInteractable> _interactables = [];

  InteractableRoom(super.id, super.name, super.description);

  InteractableRoom.withExits(
      int id, String name, String description, List<int> exits)
      : super.withExits(id, name, description, exits);
}

class Tutorial extends InteractableRoom {
  late List<String> _steps;

  Tutorial(super.id, super.name, super.description) {
    _steps = [];
  }

  Tutorial.withExits(int id, String name, String description, List<int> exits)
      : super.withExits(id, name, description, exits);
}

class BattleRoom extends InteractableRoom {
  late List<Enemy> _enemies;

  BattleRoom(super.id, super.name, super.description) {
    _enemies = [];
  }

  BattleRoom.withExits(int id, String name, String description, List<int> exits)
      : super.withExits(id, name, description, exits);
}
