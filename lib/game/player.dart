import 'inventory.dart';
import 'package:timeless_echo/notifier.dart';

class Player {
  late int _health = 90;
  int hunger = 100;
  int thirst = 100;

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
}
