import 'item.dart';

abstract class IInteractable {
  void interact(bool flag, {Item? item});
}

class Window implements IInteractable {
  bool isOpen = false;

  @override
  void interact(bool flag, {Item? item}) {
    if (flag) {
      print("You open the window.");
      isOpen = true;
    } else {
      print("You close the window.");
      isOpen = false;
    }
  }
}

class Door implements IInteractable {
  bool isOpen = false;

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
}

class LockedDoor extends Door {
  bool isLocked = true;
  final Item requiredKey;

  LockedDoor(this.requiredKey);

  void lock(bool lockFlag, {Item? item}) {
    if (lockFlag) {
      print("You lock the door.");
      isLocked = true;
    } else if (item != null && item.name == requiredKey.name) {
      print("You unlock the door using the ${item.name}.");
      isLocked = false;
    } else {
      print("You don't have the correct key to unlock this door.");
    }
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

class Trapdoor implements IInteractable {
  bool isOpen = false;

  @override
  void interact(bool flag, {Item? item}) {
    if (flag) {
      print("You open the trapdoor.");
      isOpen = true;
    } else {
      print("You close the trapdoor.");
      isOpen = false;
    }
  }
}
