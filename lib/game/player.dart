import 'inventory.dart';
import 'package:timeless_echo/notifier.dart';

class Player {
  late int health = 90;
  int hunger = 100;
  int thirst = 100;

  Controller controller = Controller();
  Inventory inventory = Inventory();

  void takeDamage(int damage) {
    health -= damage;
    if (health <= 0) {
      controller.gameOver();
    }
  }

  String printInventory() {
    return inventory.toString();
  }
}
