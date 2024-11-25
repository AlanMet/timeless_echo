class Item {
  late final String _name;
  late final String _description;
  List<String> _synonyms = [];
  late bool _takeable;
  late String _rejectionMessage;

  Item(this._name, this._description) : _takeable = true;
  Item.untakable(
      this._name, this._description, this._synonyms, this._rejectionMessage)
      : _takeable = false;

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
      print("word was found");
      return true;
    }
    if (_synonyms.contains(word)) {
      print("synonym found");
      return true;
    }
    print("not found.");
    return false;
  }
}

class Weapon extends Item {
  late final int _damage;

  Weapon(String name, String description, this._damage)
      : super(name, description);

  int get damage => _damage;
}

class Container extends Item {
  late List<Item> _items = [];
  late bool _open = false;

  Container(String name, String description) : super(name, description);

  void addItem(Item item) {
    _items.add(item);
  }

  void removeItem(Item item) {
    _items.remove(item);
  }

  String open() {
    _open = true;
    return "The $_name is now open.";
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
        items += item._name + ", ";
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

// Dummy item for when an item is not found
class Dummy extends Item {
  Dummy() : super("Dummy", "Dummy item");
}
