import 'inventory.dart';
import 'item.dart';
import 'package:timeless_echo/notifier.dart';

class Player {
  late int _health = 90;
  int hunger = 100;
  int thirst = 100;
  bool crouched = false;

  Controller controller = Controller();
  Inventory _inventory = Inventory();

  void takeDamage(int damage) {
    _health -= damage;
    if (_health <= 0) {
      controller.gameOver();
    }
  }

  String printInventory() {
    return _inventory.toString();
  }

  get inventory => _inventory;

  String eat(String itemName) {
    for (var item in _inventory.items) {
      if (item.isSynonym(itemName)) {
        if (item is Food) {
          _health += item.health;
          if (_health > 100) {
            _health = 100;
          }
          _inventory.removeItem(item.name);
          return "You ate the ${item.name}. Your health is now $_health.";
        } else {
          return "You can't eat that!";
        }
      }
    }
    return "You don't have that item!";
  }

  String drink(String itemName) {
    for (var item in _inventory.items) {
      if (item.isSynonym(itemName)) {
        if (item is Drink) {
          thirst += item.health;
          if (thirst > 100) {
            thirst = 100;
          }
          _inventory.removeItem(item.name);
          return "You drank the ${item.name}. Your thirst is now $thirst.";
        } else {
          return "You can't drink that!";
        }
      }
    }
    return "You don't have that item!";
  }
}
