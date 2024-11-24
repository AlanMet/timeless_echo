import 'item.dart';

class Inventory {
  int maxItems = 15;
  late List<Item> _items;

  Inventory() {
    _items = [];
  }

  // Item dropItem(String item) {
  // }

  bool addItem(Item item) {
    if (_items.length >= maxItems) {
      return false;
    }
    _items.add(item);
    return true;
  }

  List<Item> get items => _items;

  bool contains(Item item) {
    return _items.contains(item);
  }

  @override
  String toString() {
    if (_items.isEmpty) {
      return 'Inventory is empty';
    }
    String result = '';
    for (var item in _items) {
      result += item.name + '\n';
    }
    return result;
  }
}
