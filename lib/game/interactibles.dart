import 'item.dart';

abstract class IInteractable {
  void interact(bool flag, {Item? item});
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
  void interact(bool flag, {Item? item}) {
    if (flag) {
      print("You open the door.");
      isOpen = true;
    } else {
      print("You close the door.");
      isOpen = false;
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
  void interact(bool flag, {Item? item}) {
    if (isLocked) {
      print("The door is locked. You need the correct key.");
    } else {
      super.interact(flag);
    }
  }
}

class Rug implements IInteractable {
  final IInteractable hiddenInteractable;

  Rug(this.hiddenInteractable);

  @override
  void interact(bool flag, {Item? item}) {
    if (flag) {
      print("You move the rug and reveal something hidden.");
      hiddenInteractable.interact(true, item: item);
    } else {
      print("You place the rug back.");
    }
  }
}

class Trapdoor extends Door {
  Trapdoor(String name, int room1, int room2) : super(name, room1, room2);
}
