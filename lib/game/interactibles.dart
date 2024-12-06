import 'item.dart';

abstract class IInteractable {
  String interact(bool flag);
}

class Door implements IInteractable {
  bool isOpen = false;
  late String _name;

  List<int> _rooms = [];

  Door(String name, int room1, int room2) {
    _rooms.add(room1);
    _rooms.add(room2);
    _name = name;
  }

  @override
  String interact(bool flag) {
    if (flag) {
      isOpen = true;
      return "You open the ${_name}.";
    } else {
      isOpen = false;
      return "You close the ${_name}.";
    }
  }

  List<int> getRooms() {
    return _rooms;
  }
}

class LockedDoor extends Door {
  bool isLocked = true;
  final int requiredKey;

  LockedDoor(this.requiredKey, String name, int room1, int room2)
      : super(name, room1, room2);

  void lock(bool lockFlag, {Item? item}) {
    return;
  }

  @override
  String interact(bool flag) {
    if (flag) {
      if (isLocked) {
        return "The ${_name} is locked. You need the correct key.";
      } else {
        return super.interact(flag);
      }
    } else {
      if (!isOpen) {
        return "The ${_name} is already closed.";
      } else {
        return super.interact(flag);
      }
    }
  }
}

class Rug implements IInteractable {
  final IInteractable hiddenInteractable;

  Rug(this.hiddenInteractable);

  @override
  String interact(bool flag) {
    return "idk";
  }
}

class Trapdoor extends Door {
  Trapdoor(String name, int room1, int room2) : super(name, room1, room2);
}
