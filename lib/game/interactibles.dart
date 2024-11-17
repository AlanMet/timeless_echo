//adds interactable
abstract class IInteractable {
  void interact();
}

class Window implements IInteractable {
  @override
  void interact() {
    print("You open the window");
  }
}

class Door implements IInteractable {
  @override
  void interact() {
    print("You open the door");
  }
}

class Rug implements IInteractable {
  IInteractable hiddenInteractable;
  Rug(this.hiddenInteractable);
  @override
  void interact() {
    print("You move the rug");
    //reveal trapdoor
  }
}

class Trapdoor implements IInteractable {
  @override
  void interact() {
    //if
    print("You open the trapdoor");
  }
}
