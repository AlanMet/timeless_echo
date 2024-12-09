import 'dart:io';

import 'inventory.dart';
import 'item.dart';
import 'package:timeless_echo/notifier.dart';

class Player {
  late int _health = 90;
  int hunger = 100;
  int thirst = 100;
  bool crouched = false;

  Controller controller = Controller();
  final Inventory _inventory = Inventory();

  void takeDamage(int damage) {
    _health -= damage;
    if (_health <= 0) {
      controller.gameOver();
    }
  }

  String printInventory() {
    return "Your inventory contains:\n${_inventory.toString()}";
  }

  get inventory => _inventory;
  get health => _health;

  String eat(String itemName) {
    for (var item in _inventory.items) {
      if (item.isSynonym(itemName)) {
        if (item is Food) {
          _health += item.health;
          if (_health > 100) {
            _health = 100;
          }
          _inventory.removeItem(item.name);
          if (item is Drink) {
            return "You drank the ${item.name}. Your health is now $_health.";
          } else {
            return "You ate the ${item.name}. Your health is now $_health.";
          }
        } else {
          return "You can't eat that!";
        }
      }
    }
    return "You don't have that item!";
  }
}
