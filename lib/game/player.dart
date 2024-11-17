import 'inventory.dart';
import '\\notifier.dart';

class Player {
  late int health = 90;
  int hunger = 100;
  int thirst = 100;

  Controller controller = Controller();
  Inventory inventory = Inventory();
}
