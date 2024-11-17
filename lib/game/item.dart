class Item {
  late final String _name;
  late final String _description;
  late final List<String> _synonyms;
  late bool _takeable;
  late String _rejectionMessage;

  Item(this._name, this._description, this._synonyms) : _takeable = true;
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
    return _synonyms.contains(word) || _name == word;
  }
}
