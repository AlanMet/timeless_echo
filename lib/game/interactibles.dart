import 'item.dart';
import 'dart:developer' as developer;

abstract class IInteractable {
  String interact(bool flag);
}

class Door implements IInteractable {
  bool isOpen = false;
  late String _name;
  final List<String> _synonyms = [];

  get name => _name;

  // ignore: prefer_final_fields
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
      return "You open the $_name.";
    } else {
      isOpen = false;
      return "You close the $_name.";
    }
  }

  void addSynonym(String synonym) {
    _synonyms.add(synonym);
  }

  void addSynonyms(List<String> synonyms) {
    _synonyms.addAll(synonyms);
  }

  bool isSynonym(String word) {
    if (_name == word) {
      developer.log("word was found");
      return true;
    }
    if (_synonyms.contains(word)) {
      developer.log("synonym found");
      return true;
    }
    developer.log("not found.");
    return false;
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
        return "The $_name is locked. You need the correct key.";
      } else {
        return super.interact(flag);
      }
    } else {
      if (!isOpen) {
        return "The $_name is already closed.";
      } else {
        return super.interact(flag);
      }
    }
  }

  String unlock(int keyId) {
    if (keyId == requiredKey) {
      isLocked = false;
      return "You unlock the $_name.";
    } else {
      return "The key doesn't fit.";
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

//used to differentiate between doors and trapdoors
class Trapdoor extends Door {
  Trapdoor(super.name, super.room1, super.room2);
}
