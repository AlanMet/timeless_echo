import 'item.dart';

class Inventory {
  int maxItems = 15;
  late List<Item> _items;

  Inventory() {
    _items = [];
  }

  bool addItem(Item item) {
    if (_items.length >= maxItems) {
      return false;
    }
    _items.add(item);
    return true;
  }

  Item? removeItem(String itemName) {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isSynonym(itemName)) {
        return _items.removeAt(i);
      }
    }
    return null;
  }

  List<Item> get items => _items;

  bool contains(Item item) {
    return _items.contains(item);
  }

  Item? inInventory(String itemName) {
    for (var item in _items) {
      if (item.isSynonym(itemName)) {
        return item;
      }
    }
    return null;
  }

  Item getItem(String itemName) {
    for (var item in _items) {
      if (item.isSynonym(itemName)) {
        return item;
      }
    }
    throw ArgumentError('Item not found');
  }

  @override
  String toString() {
    if (_items.isEmpty) {
      return 'Inventory is empty';
    }
    String result = '';
    for (var item in _items) {
      result += '${item.name}\n';
    }
    return result;
  }
}
