import 'dart:developer' as developer;

class Item {
  late final int _id;
  late final String _name;
  late final String _description;
  List<String> _synonyms = [];
  late bool _takeable;
  late String _rejectionMessage;

  Item(this._id, this._name, this._description) : _takeable = true;
  Item.untakable(
      this._name, this._description, this._synonyms, this._rejectionMessage)
      : _takeable = false;

  int get id => _id;
  String get name => _name;
  String get description => _description;
  bool get takeable => _takeable;
  List<String> get synonyms => _synonyms;

  void addSynonym(String synonym) {
    _synonyms.add(synonym);
  }

  void addSynonyms(List<String> synonyms) {
    _synonyms.addAll(synonyms);
  }

  String getTakeDialogue() {
    if (takeable) {
      return "Taken $_name.";
    } else {
      return _rejectionMessage;
    }
  }

  void setTakeable(bool takeable) {
    _takeable = takeable;
  }

  bool isSynonym(String word) {
    if (_name == word) {
      developer.log("$word was found");
      return true;
    }
    if (_synonyms.contains(word)) {
      developer.log("$word synonym found");
      return true;
    }
    developer.log("not found.");
    return false;
  }
}

class Food extends Item {
  late final int _health;

  Food(super.id, super.name, super.description, this._health);

  int get health => _health;
}

class Drink extends Food {
  Drink(super.id, super.name, super.description, super.health);
}

class Weapon extends Item {
  late final int _damage;

  Weapon(super.id, super.name, super.description, this._damage);

  int get damage => _damage;
}

class Container extends Item {
  // ignore: prefer_final_fields
  late List<Item> _items = [];
  late bool _open = false;

  Container(super.id, super.name, super.description);

  bool isOpen() {
    return _open;
  }

  void addItem(Item item) {
    _items.add(item);
  }

  void removeItem(Item item) {
    _items.remove(item);
  }

  Item? removeItemByName(String itemName) {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isSynonym(itemName)) {
        return _items.removeAt(i);
      }
    }
    return null;
  }

  String open() {
    _open = true;
    String output = "The $_name is now open.\n";
    if (_items.isEmpty) {
      output += "It is empty.";
    } else {
      output += "It contains: ";
      for (int i = 0; i < _items.length; i++) {
        output += _items[i]._name;
        if (i == _items.length - 2) {
          output += " and ";
        } else if (i < _items.length - 2) {
          output += ", ";
        }
      }
    }

    return output;
  }

  String close() {
    _open = false;
    return "The $_name is now closed.";
  }

  List<Item> get items => _items;

  String describeItems() {
    if (_open) {
      if (_items.isEmpty) {
        return "The $_name is empty.";
      }
      String items = "The $_name contains: ";
      for (var item in _items) {
        items += "${item._name}, ";
      }
      return items;
    } else {
      return "";
    }
  }

  //when looking specifically at the container
  String inspect() {
    if (_open && items.isEmpty) {
      return "The $_name is empty.";
    } else {
      return describeItems();
    }
  }
}

class Book extends Item {
  late final String _text;

  Book(super.id, super.name, super.description, this._text);

  String get text => _text;

  String read() {
    return _text;
  }
}

class Enemy extends Item {
  late int _health;
  // ignore: prefer_final_fields
  late int _damage;

  bool discovered = false;
  bool started = false;

  Enemy(super.id, super.name, super.description, this._health, this._damage);

  get health => _health;

  String takeDamage(int damage) {
    _health -= damage;
    return healthStatus();
  }

  String healthStatus() {
    if (_health > 75) {
      return "The $name looks strong and healthy.";
    } else if (_health > 50) {
      return "The $name is slightly wounded.";
    } else if (_health > 25) {
      return "The $name is seriously injured.";
    } else if (_health > 0) {
      return "The $name is on the brink of death.";
    } else {
      return "The $name is dead! Great work!";
    }
  }

  int get damage => _damage;

  bool isDead() {
    return _health <= 0;
  }
}

// Dummy item for when an item is not found
class Dummy extends Item {
  Dummy() : super(-1, "Dummy", "Dummy item");
}
